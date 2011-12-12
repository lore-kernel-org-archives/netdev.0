From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Mon, 12 Dec 2011 13:57:21 +0100
Message-ID: <4EE5FA31.1080005@profihost.ag>
References: <4ED7C367.3070109@profihost.ag>	 <20111201182309.GA10686@infradead.org>	 <1322770844.2750.1.camel@edumazet-laptop>	 <CA+5PVA6kZkgYus4698Up8Q8uMTetCU2=DnTD0RpgXuHkJj6KKg@mail.gmail.com> <1322773527.2750.27.camel@edumazet-laptop> <4ED86B79.4060506@profihost.ag> <4EE5CD26.40806@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@gmail.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Dave Chinner <david@fromorbit.com>, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server655-han.de-nserver.de ([85.158.177.45]:41414 "EHLO
	server655-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752804Ab1LLM5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:57:25 -0500
In-Reply-To: <4EE5CD26.40806@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> Am 01.12.2011 22:05, schrieb Eric Dumazet:
>>> Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 15:37 -0500, Josh Boyer a =C3=
=A9crit :
>>>
>>>> Did you mean f2c31e32bf2c31e32b378a665 ?
>>>
>>> Oh well, yes ;)
>>>
>>>>> But this patch needs some followup patches (some of them in David=
 net
>>>>> tree, not yet in Linus tree)
>>>>
>>>> 9de79c127cccecb11ae6a21ab1499e87aa222880 (net: fix potential neigh=
bour
>>>> race in dst_ifdown()) is in Linus' tree.  Which others are missing=
?
>>>
>>> Hmm
>>>
>>> Linus tree :
>>>
>>> commit 580da35a31f91a594f3090b7a2c39b85cb051a12
>>> IB: Fix RCU lockdep splats
>>>
>>> David tree :
>>>
>>> commit 218fa90f072e4aeff9003d57e390857f4f35513e
>>> ipv4: fix lockdep splat in rt_cache_seq_show
>>>
>>> commit f7e57044eeb1841847c24aa06766c8290c202583
>>> sch_teql: fix lockdep splat
>

I made a backport while using these commits from v3.1.5:

5eb027bb82d1f9d4af0df73a3ce08945ffc1b481 =3D> sch_teql: fix lockdep spl=
at
de5f8dc38303f9a1fc58349f0d1c6f46a8034a00 =3D> > IB: Fix RCU lockdep spl=
ats
f667de2e66ea9b8f99353ff01221bb355faf3f3c =3D> > ipv4: fix lockdep splat=
 in
rt_cache_seq_show

9de79c127cccecb11ae6a21ab1499e87aa222880 (fix for f2c31e32b378a)
f2c31e32b378a6653f8de606149d963baf11d7d3 =3D> Fri Jul 29 19:00:53 2011
lock dep splat

d3aaeb38c40e5a6c08dd31a1b64da65c4352be36 =3D> net: Add ->neigh_lookup()
operation to dst_op

3769cffb1c48f64640ffab7ce3bffe867342c0f0 =3D> ip4 neigh lookup
f610b74b14d74a069f61583131e689550fd5bab3 =3D> arp hash func
cd0893369ca85fd11bc517081b2d9079d2ef2f90 =3D> store hash shift instread=
of mask

e049f28883126c689cf95859480d9ee4ab23b7fa =3D> fix helpers
69cce1d1404968f78b177a0314f5822d5afdbbfb =3D> introduce helper
9cbb7ecbcff85077bb12301aaf4c9b5a56c5993d =3D> ipv6: Get rid of
rt6i_nexthop macro.

Anybody interested? And if how to send my commits / diffs?

Stefan
