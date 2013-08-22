From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: fix build warning of used uninitialized
 variable
Date: Thu, 22 Aug 2013 14:15:58 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F908B16AA6@039-SN1MPN1-002.039d.mgd.msft.net>
References: <1377165637-8116-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	Zhou Luwei-B45643 <B45643@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:7841 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753552Ab3HVOQF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 10:16:05 -0400
In-Reply-To: <1377165637-8116-1-git-send-email-B38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 77ea0db..4ea1555 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -835,7 +835,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  	int	pkt_received = 0;
>  	struct	bufdesc_ex *ebdp = NULL;
>  	bool	vlan_packet_rcvd = false;
> -	u16	vlan_tag;
> +	u16	vlan_tag = 0;
> 
>  #ifdef CONFIG_M532x
>  	flush_cache_all();

Acked

> --
> 1.7.1
