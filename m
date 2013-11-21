From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 12/13] bna: Firmware Patch Simplification
Date: Wed, 20 Nov 2013 22:26:20 -0800
Message-ID: <1385015180.2164.42.camel@joe-AO722>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
	 <1385013257-32745-13-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@Brocade.COM
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0005.hostedemail.com ([216.40.44.5]:44874 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751086Ab3KUG0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:26:23 -0500
In-Reply-To: <1385013257-32745-13-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 21:54 -0800, Rasesh Mody wrote:
> This patch includes change to enable firmware patch simplication feature.
> This feature is targeted to address the requirement to have independent patch
> release for firmware. Prior to the 3.2.3.0 firmware, releasing a patch fix for
> firmware would require changes to bna driver, to use new firmware images.
> However with these changes, if the new firmware is flashed on to the Adapter,
> the driver will use the new firmware after checking the patch release byte in
> the firmware version.

Please run your patches through checkpatch --strict

> +/* flash command register data structure */
> +union bfa_flash_cmd_reg {
> +	struct {
> +#ifdef __BIGENDIAN

__BIG_ENDIAN?

> +/* flash device status register data structure */
> +union bfa_flash_dev_status_reg {
> +	struct {
> +#ifdef __BIGENDIAN

__BIG_ENDIAN here too?

> +/* flash address register data structure */
> +union bfa_flash_addr_reg {
> +	struct {
> +#ifdef __BIGENDIAN

and here
