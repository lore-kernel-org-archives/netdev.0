From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [IPv6] UDP Encapsulation of IPsec ESP Packets
Date: Thu, 24 May 2007 18:25:23 +0900
Message-ID: <1179998723.20834.10.camel@sebastian.intellilink.co.jp>
References: <E1Hr8mJ-00024X-00@gondolin.me.apana.org.au>
	 <1179997410.20254.29.camel@sebastian.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv1.oss.ntt.co.jp ([222.151.198.98]:50516 "EHLO
	serv1.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbXEXJZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 05:25:45 -0400
In-Reply-To: <1179997410.20254.29.camel@sebastian.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-24 at 18:03 +0900, Fernando Luis V=C3=A1zquez Cao wrote=
:
> On Thu, 2007-05-24 at 18:34 +1000, Herbert Xu wrote:
> > Fernando Luis V??zquez Cao <fernando@oss.ntt.co.jp> wrote:
> > > I noticed that IPv4-over-IPv6 made into 2.6.21 (thank you!) and t=
hat
> > > prompted to check the progress with the implementation of rfc3948=
 (UDP
> > > Encapsulation of IPsec ESP Packets) in Linux. For IPv4 the code i=
s
> > > already there, but that does not seem to be the case for IPv6. I =
have
> > > checked the usagi kernels and Dave S. Miller's net git tree and c=
ould
> > > not find anything.
> > >=20
> > > Is anyone working on this? I would appreciate any information on =
the
> > > status of this work.
> >=20
> > If we don't have NAT on IPv6 why would you need UDP encapsulation?
> Hi Herbert,
>=20
> Thank you for your feedback.
>=20
> Depending on the filtering rules it is possible that a gateway/firewa=
ll
> does not accept incoming ESP packets. When the filter rules of the
> firewall cannot be changed (because one is not the administrator) the
> only way of traversing the firewall is using some sort of encapsulati=
on,
> such as UDP encapsulation.
>=20
> Is there any other way to circumvent this issue?
>=20
> (By the way, the premise is that network is a pure ipv6 environment)
As an aside, RFC-3948 explicitly indicates that ESP encapsulation as
defined in the RFC can be used in both IPv4 and IPv6 scenarios. I guess
that they had cases like this in mind.

