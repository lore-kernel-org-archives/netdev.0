From: Raphael Hertzog <raphael@ouaza.com>
Subject: Re: Constantly varying download rate with a complex xen networking
	setup, why?
Date: Mon, 15 Jun 2009 18:02:54 +0200
Message-ID: <20090615160254.GA8550@rivendell>
References: <20090615075313.GA22819@rivendell> <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-15?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakeen.ouaza.com ([212.85.152.62]:60523 "EHLO
	arrakeen.ouaza.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762114AbZFOQC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 12:02:57 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 juin 2009, Ilpo J=E4rvinen a =E9crit :
> On Mon, 15 Jun 2009, Raphael Hertzog wrote:
>=20
> > My problem is that when I download a big file from the internet by =
HTTP in
> > the dom0, the download rate is not stable. It goes up progressively=
 and then
> > stalls for a few seconds, and restart again going up progressively =
(and
> > all this in loop until the download is complete).
>=20
> My guess: TCP sawtooth pattern and the associated loss recovery...? W=
hat=20
> you describe here seems to match exactly to what is expected to happe=
n=20
> because of it (I see this happening quite often actually).

Why would this not happen for the same transfer done through a proxy (t=
hat
runs on the same machine but different domU)?

> What is the size of the bottleneck buffer and base RTTs of the releva=
nt
> flows (HTTP, ssh)?

How can I collect those information?

> Please verify "blocking" using tcpdump or so. You may find out e.g. t=
hat=20

I'll try to do so and follow-up.

> network is not stalled but that out-of-order arrivals prevent=20
> applications from making progress.
>=20
> If this matches with your problem, deploying AQM at the bottleneck wo=
uld=20
> help.

The bottleneck in my test setup is the ADSL connection and I don't cont=
rol
the ADSL router.

Cheers,
--=20
Rapha=EBl Hertzog -+- http://www.ouaza.com

=46reexian : des d=E9veloppeurs Debian au service des entreprises
http://www.freexian.com
