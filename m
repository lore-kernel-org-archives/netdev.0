From: Eugenia Emantayev <eugenia@mellanox.com>
Subject: RE: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sun, 26 Feb 2012 19:12:12 +0000
Message-ID: <74A0102445410646AFACC089FD94803A616DC2FE@MTLDAG02.mtl.com>
References: <953B660C027164448AE903364AC447D2618B88E7@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:47982 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752084Ab2BZTMT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Feb 2012 14:12:19 -0500
In-Reply-To: <953B660C027164448AE903364AC447D2618B88E7@MTLDAG02.mtl.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Saturday, February 25, 2012 12:51 PM

> A driver xmit function is not allowed to change skb without special
> care.
>
> mlx4_en_xmit() should not call skb_reset_mac_header() and instead should
> use skb->data to access ethernet header.
>
> This removes a dumb test : if (ethh && ethh->h_dest)
>
> Also remove this slow mlx4_en_mac_to_u64() call, we can use
> get_unaligned() to get faster code.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
> Please test this patch before we can commit it, thanks !

Tested and approved, thanks.
--
Eugenia Emantayev
