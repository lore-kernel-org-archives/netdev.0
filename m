From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Sun, 13 Mar 2011 21:16:28 +0100
Message-ID: <1300047388.2761.48.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 10 mars 2011 =C3=A0 16:08 +0800, Po-Yu Chuang a =C3=A9crit :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTGMAC100 Ethernet Media Access Controller supports 10/100/1000 Mbps
> and MII/GMII.  This driver has been working on some ARM/NDS32 SoC's
> including Faraday A369 and Andes AG102.
>=20

Hi

It seems very close from drivers/net/ftmac100.c one. Are you sure a
factorization is not possible ?

BTW, it seems I missed the fact that ftmac100_alloc_rx_page() used a
GFP_KERNEL allocation, while its called from softirq context (from
ftmac100_rx_packet())=20


Same problem of course in this Gigabit driver.
