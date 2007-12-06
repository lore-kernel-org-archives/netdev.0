From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 5 Dec 2007 21:06:49 -0700
Message-ID: <20071205210649.5a3d1a52@shemminger-laptop>
References: <20071205.053031.87154402.davem@davemloft.net>
	<1196873587.10819.30.camel@localhost>
	<20071205163338.50aff45d@shemminger-laptop>
	<Pine.LNX.4.64.0712052336240.9572@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59138 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751963AbXLFEIA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 23:08:00 -0500
In-Reply-To: <Pine.LNX.4.64.0712052336240.9572@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Dec 2007 00:15:49 +0200 (EET)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Wed, 5 Dec 2007, Stephen Hemminger wrote:
>=20
> > On Wed, 05 Dec 2007 08:53:07 -0800
> > Joe Perches <joe@perches.com> wrote:
> >=20
> > > > it occurred to me that we might want to do something
> > > > like a state change event generator.
> > >=20
> > > This could be a basis for an interesting TCP
> > > performance tester.
> >=20
> > That is what tcpprobe does but it isn't detailed enough to address =
SACK
> > issues.
>=20
> ...It would be nice if that could be generalized so that the probe co=
uld=20
> be attached to some other functions than tcp_rcv_established instead.
>=20
> If we convert remaining functions that don't have sk or tp as first=20
> argument so that sk is listed first (should be many with wrong orderi=
ng=20
> if any), then maybe a generic handler could be of type:
>=20
> jtcp_entry(struct sock *sk, ...)
>=20
> or when available:
>=20
> jtcp_entry(struct sock *sk, struct sk_buff *ack, ...)
>=20
>=20
> --=20
>  i.

An earlier version had hooks in send as well, it is trivial to extend. =
as long as
the prototypes match, any function arg ordering is okay.
