From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] e1000e: use resource_size_t, not unsigned long, for phys
 addrs
Date: Thu, 22 May 2008 06:22:03 -0400
Message-ID: <4835494B.20802@pobox.com>
References: <Pine.LNX.4.64.0805011757090.8700@monty.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Becky Bruce <bgill@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59314 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933393AbYEVKWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:22:07 -0400
In-Reply-To: <Pine.LNX.4.64.0805011757090.8700@monty.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Becky Bruce wrote:
> The use of unsigned long causes the driver to fail on 32-bit systems
> which support 64-bit resources.
> 
> Signed-off-by: Becky Bruce <becky.bruce@freescale.com>
> ---
> 
> Resend, with proper CC.
> 
>  drivers/net/e1000e/netdev.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 8991ab8..dae3269 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3897,8 +3897,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>  	struct e1000_adapter *adapter;
>  	struct e1000_hw *hw;
>  	const struct e1000_info *ei = e1000_info_tbl[ent->driver_data];
> -	unsigned long mmio_start, mmio_len;
> -	unsigned long flash_start, flash_len;
> +	resource_size_t mmio_start, mmio_len;
> +	resource_size_t flash_start, flash_len;
>  

applied


