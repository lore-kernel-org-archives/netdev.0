From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 34/72] skge/sky2: Move the SysKonnect Ethernet drivers
Date: Sat, 25 Jun 2011 16:49:13 +0200
Message-ID: <201106251649.13877.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-35-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58050 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab1FYOtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:49:49 -0400
In-Reply-To: <1309010363-22750-35-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> Move the SysKonnect Ethernet drivers into drivers/net/ethernet/syskonnect/
> and make the necessary Kconfig and Makefile changes.
> 
> CC: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                  |    3 +-
>  drivers/net/Kconfig                          |   58 --------------------
>  drivers/net/Makefile                         |    2 -
>  drivers/net/ethernet/Kconfig                 |    1 +
>  drivers/net/ethernet/Makefile                |    1 +
>  drivers/net/ethernet/syskonnect/Kconfig      |   74 ++++++++++++++++++++++++++
>  drivers/net/ethernet/syskonnect/Makefile     |    6 ++
>  drivers/net/{ => ethernet/syskonnect}/skge.c |    0
>  drivers/net/{ => ethernet/syskonnect}/skge.h |    0
>  drivers/net/{ => ethernet/syskonnect}/sky2.c |    0
>  drivers/net/{ => ethernet/syskonnect}/sky2.h |    0

Shouldn't these live together with the other Marvell drivers?

	Arnd
