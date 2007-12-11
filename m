From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] Increase virtual FIFOs in ucc_geth.
Date: Tue, 11 Dec 2007 17:49:46 +0800
Message-ID: <989B956029373F45A0B8AF029708189001B4D901@zch01exm26.fsl.freescale.net>
References: <1197312366-7484-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:36693 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbXLKJuD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 04:50:03 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id lBB9np9c018320
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 02:49:52 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id lBB9nomT012661
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 03:49:51 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <1197312366-7484-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> Sent: Tuesday, December 11, 2007 2:46 AM
> To: Li Yang-r58472 <LeoLi@freescale.com> Netdev
> Cc: Joakim Tjernlund
> Subject: [PATCH] Increase virtual FIFOs in ucc_geth.
> 
> Increase UCC_GETH_URFS_INIT to 1152 and
> UCC_GETH_UTFS_INIT to 896 to avoid HW Overrun/Underrun.

Please be noted that these values are only used for 10/100Mbps speed.
Did you get Overrun in 10/100M mode?

- Leo

> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h 
> index bb4dac8..d3f030b 100644
> --- a/drivers/net/ucc_geth.h
> +++ b/drivers/net/ucc_geth.h
> @@ -923,11 +923,11 @@ struct ucc_geth_hardware_statistics {
>  #define PHY_CHANGE_TIME                         2
>  
>  /* Fast Ethernet (10/100 Mbps) */
> -#define UCC_GETH_URFS_INIT                      512	/* Rx 
> virtual FIFO size
> +#define UCC_GETH_URFS_INIT                      1152	/* Rx 
> virtual FIFO size
>  							 */
>  #define UCC_GETH_URFET_INIT                     256	/* 1/2 urfs */
>  #define UCC_GETH_URFSET_INIT                    384	/* 3/4 urfs */
> -#define UCC_GETH_UTFS_INIT                      512	/* Tx 
> virtual FIFO size
> +#define UCC_GETH_UTFS_INIT                      896	/* Tx 
> virtual FIFO size
>  							 */
>  #define UCC_GETH_UTFET_INIT                     256	/* 1/2 utfs */
>  #define UCC_GETH_UTFTT_INIT                     128
> --
> 1.5.3.6
> 
> 
