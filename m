From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix typo
Date: Tue, 29 Apr 2008 20:18:59 +0800
Message-ID: <989B956029373F45A0B8AF029708189002007ED7@zch01exm26.fsl.freescale.net>
References: <1209470569-31270-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>,
	"Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:64126 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbYD2MTG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 08:19:06 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3TCJ3TK016264
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 05:19:03 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m3TCJ0N3018465
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 07:19:01 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1209470569-31270-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> Sent: Tuesday, April 29, 2008 8:03 PM
> To: Li Yang; Netdev
> Cc: Joakim Tjernlund
> Subject: [PATCH] ucc_geth_ethtool: Fix typo
> 
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Acked-by: Li Yang <leoli@freescale.com>

> ---
>  drivers/net/ucc_geth_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_ethtool.c 
> b/drivers/net/ucc_geth_ethtool.c index 9a9622c..a995a3a 100644
> --- a/drivers/net/ucc_geth_ethtool.c
> +++ b/drivers/net/ucc_geth_ethtool.c
> @@ -314,7 +314,7 @@ static void uec_get_strings(struct 
> net_device *netdev, u32 stringset, u8 *buf)
>  		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
>  	}
>  	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
> -		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
> +		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
>  			       	ETH_GSTRING_LEN);
>  }
>  
> --
> 1.5.5.1
> 
> 
