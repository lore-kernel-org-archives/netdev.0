From: Simon Horman <horms@verge.net.au>
Subject: Re: [net] r8169   Remove duplicate command which set RxVlan and
 RxChksum bits.
Date: Thu, 18 Feb 2016 14:25:43 +0900
Message-ID: <20160218052543.GA15955@verge.net.au>
References: <1454254388-15523-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45932 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424723AbcBRFZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 00:25:54 -0500
Content-Disposition: inline
In-Reply-To: <1454254388-15523-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 31, 2016 at 05:33:08PM +0200, Corcodel Marian wrote:
>  These bits is already set on set geatures stage.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 17d5571..a8fb86d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -8368,7 +8368,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
>  		NETIF_F_HIGHDMA;
>  
> -	tp->cp_cmd |= RxChkSum | RxVlan;
>  

To avoid two consecutive blank lines, which seems excessive here,
you may want to consider removing the blank line before or after the
line of code you are removing.

>  	/*
>  	 * Pretend we are using VLANs; This bypasses a nasty bug where
> -- 
> 2.5.0
> 
