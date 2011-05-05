From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Thu, 05 May 2011 08:57:15 +0200
Message-ID: <1304578635.32152.800.camel@edumazet-laptop>
References: <4DC156AF.4050807@mellanox.co.il>
	 <1304520260.3203.34.camel@localhost>
	 <1304527586.32152.5.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2070B8E35@mtldag01.mtl.com>
	 <1304578518.32152.794.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35093 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab1EEG5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 02:57:21 -0400
Received: by wwa36 with SMTP id 36so2017927wwa.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 23:57:19 -0700 (PDT)
In-Reply-To: <1304578518.32152.794.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 mai 2011 =C3=A0 08:55 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 05 mai 2011 =C3=A0 06:47 +0000, Yevgeny Petrilin a =C3=A9cri=
t :
> > >=20
> > Eric, you are correct.
> > We do plan to enable full 32 bit hash for our devices.
> > Once it is done, we will naturally use the whole 32 bits.
> > In the meanwhile, even with this change we see improved performance=
 when enabling RPS.
>=20
> Hmm, thats strange because you have only 256 possible values for rxha=
sh,
> and it's OK for maybe one hundred flows. (I am talking not of RPS but
> RFS here)
>=20
> So your patch is a win only for small hosts, or particular workloads
> (did I say biased benchmarks ? ;) )
>=20
> Really, we better use the linux/software full 32bit rxhash in this ca=
se,
> and wait for your 32bit full support.
>=20
>=20

BTW, before you submit another rxhash patch, please make sure ethtool
support is included. An admin must be able to switch off hardware
support :

ethtool -K eth0 rxhash off



