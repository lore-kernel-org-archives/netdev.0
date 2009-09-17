From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: [ANNOUNCE] new iptables module match large amount of ip addresses
Date: Thu, 17 Sep 2009 22:36:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909172232340.32723@artax.karlin.mff.cuni.cz>
References: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
 <1253217817.21074.9.camel@ice-age>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1908654874-237646716-1253219817=:32723"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Leblond <eric@inl.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1253217817.21074.9.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1908654874-237646716-1253219817=:32723
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 17 Sep 2009, Eric Leblond wrote:

> Hi,
>=20
> Le jeudi 17 septembre 2009 a 21:15 +0200, Mikulas Patocka a =E9crit :
> > Hi
> >=20
> > Here I submit an iptables module that can match large amounts (millions=
)=20
> > of ip addresses efficiently using binary search.
>=20
> What are the differences with ipset ? (http://ipset.netfilter.org/)
>=20
> BR,

What I wrote is static --- once loaded, then used. The only way to update=
=20
the addresses is to reload it. Ipset is dynamic (and has more memory=20
consumption because of it). In my implementation, the kernel reads the ip=
=20
addresses, in ipset, the userspace tool reads them.=20

I didn't know about ipset before because it is not in the kernel (will it=
=20
ever be?)

Mikulas
--1908654874-237646716-1253219817=:32723--
