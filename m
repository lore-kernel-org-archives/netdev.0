From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ath9k: fix a memory leak in ath_rx_tasklet()
Date: Wed, 21 Mar 2012 03:21:03 -0700
Message-ID: <1332325263.25742.17.camel@edumazet-laptop>
References: <1331844209.19406.11.camel@edumazet-glaptop>
	 <20120316140010.GB2563@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>,
	Paul Stewart <pstew@chromium.org>,
	netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:34180 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab2CUKVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 06:21:11 -0400
Received: by dady9 with SMTP id y9so1315557dad.10
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 03:21:11 -0700 (PDT)
In-Reply-To: <20120316140010.GB2563@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 mars 2012 =C3=A0 10:00 -0400, John W. Linville a =C3=A9c=
rit :
> On Thu, Mar 15, 2012 at 01:43:29PM -0700, Eric Dumazet wrote:
> > commit 0d95521ea7 (ath9k: use split rx buffers to get rid of order-=
1 skb
> > allocations) added in memory leak in error path.
> >=20
> > sc->rx.frag should be cleared after the pskb_expand_head() call, or=
 else
> > we jump to requeue_drop_frag and leak an skb.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Jouni Malinen <jouni@qca.qualcomm.com>
> > Cc: Felix Fietkau <nbd@openwrt.org>
> > Cc: John W. Linville <linville@tuxdriver.com>
> > Cc: Trond Wuellner <trond@chromium.org>
> > Cc: Grant Grundler <grundler@chromium.org>
> > Cc: Paul Stewart <pstew@chromium.org>
> > Cc: David Miller <davem@davemloft.net>
>=20
> Acked-by: John W. Linville <linville@tuxdriver.com>
>=20
> Dave, will you pick this up yourself?  Or should I take it around the=
 bend?

I dont know, please make sure its not lost anyway :

I have an upcoming patch on top on this one to reduce ath9k skb truesiz=
e
by 50% and get better tcp receives.
