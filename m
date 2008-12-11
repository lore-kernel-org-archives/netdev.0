From: Mathieu SEGAUD <mathieu.segaud@regala.cx>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Thu, 11 Dec 2008 14:27:45 +0100
Message-ID: <8763lqj0z2.fsf@barad-dur.regala.cx>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx>
	<20081211102421.GB4129@ff.dom.local>
	<20081211104303.GC4129@ff.dom.local>
	<20081211104954.GA25179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	kernel@gentoo.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from def92-3-81-56-114-101.fbx.proxad.net ([81.56.114.101]:42519
	"EHLO barad-dur.regala.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbYLKN0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:26:44 -0500
In-Reply-To: <20081211104954.GA25179@gondor.apana.org.au> (Herbert Xu's message of "Thu\, 11 Dec 2008 21\:49\:54 +1100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vous m'avez dit r=E9cemment :

> On Thu, Dec 11, 2008 at 10:43:03AM +0000, Jarek Poplawski wrote:
>> On Thu, Dec 11, 2008 at 10:24:21AM +0000, Jarek Poplawski wrote:
>> ...
>> > Could you try e.g. 2.6.27.7 or something with this patch?:
>> >=20
>> > http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.27.y.=
git;a=3Dcommit;h=3D58ec3b4db9eb5a28e3aec5f407a54e28f7039c19
>>=20
>> Oops! 2.6.27.4 has this too...
>
> Right, this fixes a dead-lock that causes the RTNL to be held which
> doesn't seem to be the case here.  It sounds like the problem in
> this thread is simply due to a non-zero ref count on the netdev
> itself.
>
> Mathieu, you should get a message like this
>
> 	unregister_netdevice: waiting for %s to become free. Usage count =3D=
 %d
>
> What does your count say?
>
> Thanks,

sorry for the delay, the count, in this dump, is stuck at count 3.
unregister_netdevice: waiting for vbr447429 to become free. Usage count=
 =3D 3


--=20
Mathieu
