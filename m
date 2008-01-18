From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.25]  New driver "sfc" for Solarstorm SFC4000 controller
 - 5th attempt
Date: Fri, 18 Jan 2008 15:03:28 -0500
Message-ID: <47910610.3050207@pobox.com>
References: <4790D1CD.80500@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	spope@solarflare.com
To: Robert Stonehouse <rstonehouse@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39455 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbYARUDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:03:36 -0500
In-Reply-To: <4790D1CD.80500@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Stonehouse wrote:
> This is a resubmission of a new driver for Solarflare network controllers.
> 
> The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
> different 10G and 1G boards. There is a driver for the network controller
> and an MTD driver that allows access to the flash/EEPROM.
> 
> NICs based on this controller are now available from SMC as part numbers
> SMC10GPCIe-XFP and SMC10GPCIe-10BT.
> 
> FYI the previous thread was:
>   http://marc.info/?l=linux-netdev&m=119999015817920&w=2
> 
> In previous postings we were asked to have the MTD part of this patch
> reviewed and we have responded to the comments received so far:
>   http://lists.infradead.org/pipermail/linux-mtd/2008-January/020355.html
> 
> Things that have changed since the last patch:
>  - Removed residual support for more than one port per controller.
>  - Moved LED control from PHY operations to board operations.
>  - Added support for controlling LRO through ethtool {get,set}_flags().
>  - Removed obsolete workaround for reservation of MSI-X tables by PCI core.
>  - Improved reliability of PHY loopback setting.
>  - Improved reliability of I2C operations.
>  - Fixed on-load self-test when using RSS.
>  - Simplified MTD driver following review on linux-mtd list.
>  - Removed some redundant information from struct efx_nic.
>  - hardware monitoring (for PHY link polling) is now a workqueue item
> rather than using a timer
>  - mac_lock becomes a mutex to support the previous item.
> 
> We would welcome more review of this code and would like to know if there
> are any objections to this being merged for 2.6.25.
> 
> 
> The patch (against net-2.6.25) is at:
>   https://support.solarflare.com/netdev/5/net-2.6.25-sfc-2.2.0045.patch
> 
> The new files may also be downloaded as a tarball:
>   https://support.solarflare.com/netdev/5/net-2.6.25-sfc-2.2.0045.tgz
> 
> And for verification there is:
>   https://support.solarflare.com/netdev/5/MD5SUMS

Please email to me in patch format...


