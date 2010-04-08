From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: linux-next: powerpc boot failure
Date: Thu, 08 Apr 2010 10:29:49 +0300
Message-ID: <4BBD85ED.4090209@iki.fi>
References: <20100408165848.38f75f40.sfr@canb.auug.org.au>	<4BBD81B3.3030500@iki.fi> <20100408172316.e6ee451d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100408172316.e6ee451d.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> On Thu, 08 Apr 2010 10:11:47 +0300 Timo Ter=E4s <timo.teras@iki.fi> w=
rote:
>>> The above pc is in this piece of code (I think - I don't have the a=
ctual
>>> kernel) from __xfrm_lookup (in net/xfrm/xfrm_policy.c):
>>>
>>>         if ((flags & XFRM_LOOKUP_ICMP) &&
>>>             !(pols[0]->flags & XFRM_POLICY_ICMP)) {
>>>                 err =3D -ENOENT;
>>>                 goto error;
>>>         }
>>>
>>>         for (i =3D 0; i < num_pols; i++)
>>>                 pols[i]->curlft.use_time =3D get_seconds(); <------=
-- (line 1845)
>>>
>>> And the 0x200000025 is probably &(pols[i]) (which actually seems un=
likely
>>> since pols is an array on the stack).
>> What kind of xfrm policies the system has?
>=20
> I don't even know what an xfrm policy is :-).  This is a pretty norma=
l Ubuntu
> Gutsy install and wouldn't have anything special in its network setup=
=2E
>=20
> The above code fragment may be not quite the right place, sorry.  But=
 it
> is the right function.

You don't probably have any xfrm policies then. And that code should no=
t
really get executed.

Some of the changes touch globally visible structs, and inline function=
s.
Was this a clean rebuild? And did you update all kernel modules, also i=
n
the initramfs?
