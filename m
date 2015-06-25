From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [v2,9/9] fsl/fman: Add FMan MAC driver
Date: Fri, 26 Jun 2015 01:06:30 +0200
Message-ID: <1435273590.28572.11.camel@tiscali.nl>
References: <1435174672-4608-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com
To: igal.liberman@freescale.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:41283 "EHLO
	lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751507AbbFYXGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 19:06:34 -0400
In-Reply-To: <1435174672-4608-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Evolution 3.16 is basically unbearable for replying to patches. Anyone
else running into this?) 

On Wed, 2015-06-24 at 22:37 +0300, igal.liberman@freescale.com wrote:
> 
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/mac/mac-api.c
> +int set_mac_active_pause(struct mac_device *mac_dev, bool rx, bool tx)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(set_mac_active_pause);

Which module is using this function?

> +void get_pause_cfg(struct mac_device *mac_dev, bool *rx_pause, bool *tx_pause)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(get_pause_cfg);

This exports a function that is only used in this file. Why? 

Thanks,


Paul Bolle
