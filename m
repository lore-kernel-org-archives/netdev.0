From: Wolfgang Walter <linux@stwm.de>
Subject: Re: GRO: forwading ISATAP packets is very slow with kernel 4.1
Date: Wed, 15 Jul 2015 02:34:41 +0200
Message-ID: <8145949.lUzHGl5xdY@h2o.as.studentenwerk.mhn.de>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de> <20150715000848.GC29279@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:38025 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752625AbbGOAeo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 20:34:44 -0400
In-Reply-To: <20150715000848.GC29279@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 15. Juli 2015, 08:08:49 schrieben Sie:
> On Wed, Jul 15, 2015 at 12:16:30AM +0200, Wolfgang Walter wrote:
> > Hello,
> >=20
> > I upgraded routers from 3.14.x to 4.1.2. Forwarding ISATAP-packets =
(IPv4
> > packets with IPv6 payload) is very slow with 4.1 if GRO is enabled
> > (youtube
> > for example about 64kbit). Disabling GRO on the interfaces restores
> > performance to values comparable to 3.14.x.
> >=20
> > The kernel is build with IPv6 support but IPv6 is disabled via kern=
el
> > command line. The router is not a tunnel endpoint, it only forwards=
 the
> > ISATAP- packets. MTU is 1500 on both interfaces. Netfilter conntrac=
k is
> > not used and disabling netfilter has no effect.
>=20
> Can you run some tcpdumps and post the results in the two cases?
>=20

Yes, but I need the cooperation of one of our customers.

I wonder if the router may treat all ipv6-tcp connections of a host as =
a=20
single flow as all those ipv6-packets are embedded in ipv4-packets with=
 the=20
ipv4-address of the host and the ipv4-address of the isatap-gateway and=
 next-
header is 41. It may only looks at those?

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
