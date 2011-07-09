From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 02/21] net: 3c59x: use common rx_copybreak handling
Date: Sun, 10 Jul 2011 00:22:58 +0200
Message-ID: <20110709222258.GA5642@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <5a242c5dbd6222d87b77a22b9c6fe6cdfa0351f3.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40547 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab1GIWhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 18:37:20 -0400
Content-Disposition: inline
In-Reply-To: <5a242c5dbd6222d87b77a22b9c6fe6cdfa0351f3.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 8cc2256..456726c 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
[...]
> +			skb =3D dev_skb_finish_rx_dma(&vp->rx_skbuff[entry],
> +				pkt_len, rx_copybreak,
> +				&VORTEX_PCI(vp)->dev, dma, PKT_BUF_SZ);
> +			if (skb)

s/if (skb)/if (vp->rx_skbuff[entry])/ probably

--=20
Ueimor
