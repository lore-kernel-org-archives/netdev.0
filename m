From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 10:10:12 -0400
Message-ID: <4694E4C4.6010404@hp.com>
References: <200707102111.18824@auguste.remlab.net> <20070711.212916.36390936.yoshfuji@linux-ipv6.org> <200707111544.43151.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:42997 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763057AbXGKOZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 10:25:01 -0400
In-Reply-To: <200707111544.43151.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=C3=A9mi Denis-Courmont wrote:
> On Wednesday 11 July 2007 15:29:16 YOSHIFUJI Hideaki / =E5=90=89=E8=97=
=A4=E8=8B=B1=E6=98=8E wrote:
>> In article <200707102111.18824@auguste.remlab.net> (at Tue, 10 Jul 2=
007=20
> 21:11:17 +0300), Remi Denis-Courmont <rdenis@simphalempin.com> says:
>>> ICMPv6 Router Advertisements may now contain informations that is
>>> mostly of interest to userland. This currently mostly consists of
>>> recursive DNS server addresses (though one should expect other
>>> stuff to come).
>> I really do not want to have such non-standard API in kernel.
>=20
> I can only think of a very limited set of ways to extract options fro=
m RAs=20
> that the kernel currently ignores:
>=20
> 1) parse everything in kernel addrconf.c
> 2) validate RA in kernel, parse userland options in userland

Yes, #2 is the right option.  However, I agree that passing such info w=
ith
non-standard socket option is not ideal.

Since you asked for another idea, how about using netlink to send _vali=
dated_ RA
information to interested parties?

-vlad



