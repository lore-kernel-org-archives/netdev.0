From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 01 Dec 2011 22:05:27 +0100
Message-ID: <1322773527.2750.27.camel@edumazet-laptop>
References: <4ED7C367.3070109@profihost.ag>
	 <20111201182309.GA10686@infradead.org>
	 <1322770844.2750.1.camel@edumazet-laptop>
	 <CA+5PVA6kZkgYus4698Up8Q8uMTetCU2=DnTD0RpgXuHkJj6KKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>,
	Stefan Priebe <s.priebe@profihost.ag>, netdev@vger.kernel.org,
	Dave Chinner <david@fromorbit.com>, stable@vger.kernel.org
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40599 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab1LAVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:05:32 -0500
In-Reply-To: <CA+5PVA6kZkgYus4698Up8Q8uMTetCU2=DnTD0RpgXuHkJj6KKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 15:37 -0500, Josh Boyer a =C3=A9c=
rit :

> Did you mean f2c31e32bf2c31e32b378a665 ? =20

Oh well, yes ;)

> > But this patch needs some followup patches (some of them in David n=
et
> > tree, not yet in Linus tree)
>=20
> 9de79c127cccecb11ae6a21ab1499e87aa222880 (net: fix potential neighbou=
r
> race in dst_ifdown()) is in Linus' tree.  Which others are missing?

Hmm

Linus tree :

commit 580da35a31f91a594f3090b7a2c39b85cb051a12
IB: Fix RCU lockdep splats

David tree :

commit 218fa90f072e4aeff9003d57e390857f4f35513e
ipv4: fix lockdep splat in rt_cache_seq_show

commit f7e57044eeb1841847c24aa06766c8290c202583
sch_teql: fix lockdep splat
