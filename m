From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Wed, 14 May 2008 18:37:13 +0800
Message-ID: <989B956029373F45A0B8AF0297081890022E13C3@zch01exm26.fsl.freescale.net>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>,
	"Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43720 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbYENKhU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 06:37:20 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m4EAbGsX017259
	for <netdev@vger.kernel.org>; Wed, 14 May 2008 03:37:17 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m4EAbEQc013717
	for <netdev@vger.kernel.org>; Wed, 14 May 2008 05:37:15 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joakim,

I admit that I missed one in tx firmware stats.  But why are you
deleting the other two?

- Leo

> -----Original Message-----
> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> Sent: Tuesday, May 13, 2008 4:05 PM
> To: Netdev; Li Yang
> Cc: Joakim Tjernlund
> Subject: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> 
> Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> Fix it and a few others while I am there. Strangely, the 
> rx-jumbo-frames counter still counts pkgs even though I think 
> there isn't any packtes above 1518.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> Havn't seen this go in or ACK/NACK. Resending.
> 
>  drivers/net/ucc_geth_ethtool.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_ethtool.c 
> b/drivers/net/ucc_geth_ethtool.c index a995a3a..0eddf50 100644
> --- a/drivers/net/ucc_geth_ethtool.c
> +++ b/drivers/net/ucc_geth_ethtool.c
> @@ -60,7 +60,6 @@ static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
>  	"rx-broadcast-frames",
>  	"stats-counter-carry",
>  	"stats-counter-mask",
> -	"rx-dropped-frames",
>  };
>  
>  static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = { @@ 
> -73,6 +72,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
>  	"tx-frames-ok",
>  	"tx-excessive-differ-frames",
>  	"tx-256-511-frames",
> +	"tx-512-1023-frames",
>  	"tx-1024-1518-frames",
>  	"tx-jumbo-frames",
>  };
> @@ -101,7 +101,6 @@ static char 
> rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
>  	"rx-vlan-removed",
>  	"rx-vlan-replaced",
>  	"rx-vlan-inserted",
> -	"rx-ip-checksum-errors",
>  };
>  
>  #define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
> --
> 1.5.5.1
> 
> 
