From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Fri, 16 Jan 2004 00:54:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.005443.92504522.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58.0401151705500.29722@rhea.tcs.hut.fi>
	<20040116.001317.73950271.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi> (at Thu, 1=
5 Jan 2004 17:34:50 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> sa=
ys:

> On Fri, 16 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:
>=20
> > net/ipv4/arp.c:
> > | *              Alan Cox        :       Don't proxy across hardware =
types!
> >
> > This implies that proxy works across devices and
> > it is NOT what the "proxy" does in rfc2461.
>=20
> Yes, as Pekka said, Thaler's proxy is like proxy ARP.

So, all usage of pneigh_XXX() is not for rfc2461 but for proxy arp.
1) We need to consider how to implement rfc2461-proxy.
2) We need to revisit all usages in net/ipv6.

> In the current implementation the proxying router captures the multicas=
t
> queries since it has joined the solicited-node multicast group, but it
> doesn't capture the unicast queries.

It is VERY strange to handle multicast / unicast in different way.
I really hate such a hetero (or an inconsistent) implementation.


> This is what I want to fix.

I understand the issue, but the fix is unappropriate.

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
