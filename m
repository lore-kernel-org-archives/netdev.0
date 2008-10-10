From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Fri, 10 Oct 2008 10:57:57 +0200
Message-ID: <20081010085757.GA27597@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <200810101059.25904.rdenis@simphalempin.com> <20081010081022.GA27187@1wt.eu> <200810101144.06869.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4695 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756148AbYJJI6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 04:58:00 -0400
Content-Disposition: inline
In-Reply-To: <200810101144.06869.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 11:44:06AM +0300, R=E9mi Denis-Courmont wrote:
> On Friday 10 October 2008 11:10:22 ext Willy Tarreau, you wrote:
> > > Duh? If you require a SYN from the outside to the server, before =
you
> > > allow the server to send either SYN or SYN/ACK, I fail to see the
> > > problem.
> >
> > Requiring the firewall to expect a first SYN to come from the inter=
net is
> > like doing no check at all.
>=20
> On ports which are open to the outside you MUST allow inbound SYNs an=
yway.=20
> >From a security perspective, it does not matter whether the server a=
nswers=20
> with a SYN/ACK as normally or with a SYN-not-ACK as in "simultaneous =
open".
>=20
> On ports which the server is using outbound only (if any), you can ex=
pect the=20
> server to send a SYN out first. It again does not matter whether the =
other=20
> end answers with a SYN/ACK or a SYN-not-ACK.
>=20
> On other ports, a plain dumb stateless blackhole will do.
>=20
> > When your server has been rooted, you can=20
> > pretty much expect that your guest has no problem sending you a SYN=
=2E
>=20
> And why would (s)he have problem sending a SYN/ACK? It makes no diffe=
rence.

It's just that it would be useless. If sending a fake SYN from port 25 =
to your
server's port 443 allows it to establish connections from port 443 to p=
ort 25,
it becomes an easy spam platform. That's just an example. I'm just tryi=
ng to
explain that supporting simultaneous connect on a firewall prevents you=
 from
precisely controlling the direction of the streams.

Willy

