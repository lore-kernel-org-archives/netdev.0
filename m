From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Sun, 18 Sep 2011 22:39:09 +0200
Message-ID: <1316378349.31335.34.camel@edumazet-laptop>
References: <4E696FD0.7060702@intel.com>
	 <20110909015429.GA9156@gondor.apana.org.au> <4E6975B2.8000603@intel.com>
	 <alpine.DEB.2.00.1109091050550.11963@melkinpaasi.cs.helsinki.fi>
	 <CAA93jw7L9KyXVevZ8dqE+ExLYP9=CLMmj1gPD88ihBuC6ZovOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35528 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756677Ab1IRUjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 16:39:17 -0400
Received: by wwf22 with SMTP id 22so7139222wwf.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 13:39:16 -0700 (PDT)
In-Reply-To: <CAA93jw7L9KyXVevZ8dqE+ExLYP9=CLMmj1gPD88ihBuC6ZovOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 17 septembre 2011 =C3=A0 11:30 -0700, Dave Taht a =C3=A9crit =
:

>=20
> As cerowrt is one of the few projects enabling sack/dsack/ecn by
> default, it would be good to know either
>=20

dsack is enabled by default on linux, not only cerowt project.

> A) how to test to see if this problem is really a problem
> B) should we apply the obvious fix

Isnt Cerowrt a router, most of frames are forwarded anyway ?

This bug is relevant to linux hosts, receiving Duplicate Sacks (RFC
2883).
