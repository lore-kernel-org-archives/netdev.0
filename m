From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: Don't use RX clock as TX clock.
Date: Tue, 29 Apr 2008 19:07:56 +0800
Message-ID: <989B956029373F45A0B8AF029708189002007ED5@zch01exm26.fsl.freescale.net>
References: <1209467037-30612-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>,
	"Netdev" <netdev@vger.kernel.org>,
	"Tabi Timur" <timur@freescale.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:41211 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbYD2LIF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 07:08:05 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3TB7wrv008212
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 04:07:58 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3TB7uwK023844
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 06:07:57 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1209467037-30612-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> Sent: Tuesday, April 29, 2008 7:04 PM
> To: Netdev; Li Yang; Tabi Timur
> Cc: Joakim Tjernlund
> Subject: [PATCH] ucc_geth: Don't use RX clock as TX clock.
> 
> Commit 9fb1e350e16164d56990dde036ae9c0a2fd3f634,
> ucc_geth: use rx-clock-name and tx-clock-name device tree 
> properties Introduced a typo that made the driver use the RX 
> clock as TX clock, causing massive TX errors.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Acked-by: Li Yang <leoli@freescale.com>

> ---
> 
> Resending as the first one got rejected du to missing commas.
> 
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> index 28431aa..2de153f 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3907,7 +3907,7 @@ static int ucc_geth_probe(struct 
> of_device* ofdev, const struct of_device_id *ma
>  			return -EINVAL;
>  		}
>  	} else {
> -		prop = of_get_property(np, "rx-clock", NULL);
> +		prop = of_get_property(np, "tx-clock", NULL);
>  		if (!prop) {
>  			printk(KERN_ERR
>  				"ucc_geth: mising tx-clock-name 
> property\n");
> --
> 1.5.5.1
> 
> 
