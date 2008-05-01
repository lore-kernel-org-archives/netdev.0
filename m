From: "Kok, Auke" <sofar@foo-projects.org>
Subject: Re: [PATCH] e1000e: use resource_size_t, not unsigned long, for phys
 addrs
Date: Thu, 01 May 2008 16:53:49 -0700
Message-ID: <481A580D.1090200@foo-projects.org>
References: <Pine.LNX.4.64.0805011757090.8700@monty.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Becky Bruce <bgill@freescale.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:50482 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752547AbYEAXzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 19:55:20 -0400
In-Reply-To: <Pine.LNX.4.64.0805011757090.8700@monty.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Becky Bruce wrote:
> The use of unsigned long causes the driver to fail on 32-bit systems
> which support 64-bit resources.
> 
> Signed-off-by: Becky Bruce <becky.bruce@freescale.com>

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

thanks Becky,

Auke

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
>  	static int cards_found;
>  	int i, err, pci_using_dac;

