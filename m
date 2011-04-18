From: Alex Dubov <oakad@yahoo.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured incorrectly in fiber mode
Date: Sun, 17 Apr 2011 22:44:31 -0700 (PDT)
Message-ID: <572662.57492.qm@web37607.mail.mud.yahoo.com>
References: <BANLkTikJ60ND7s5-jfGTBDG3BoM-294CSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37607.mail.mud.yahoo.com ([209.191.87.90]:43439 "HELO
	web37607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751355Ab1DRFoc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 01:44:32 -0400
In-Reply-To: <BANLkTikJ60ND7s5-jfGTBDG3BoM-294CSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > --- On Thu, 14/4/11, Andy Fleming <afleming@gmail.com>
> wrote:
> >
> >>
> >
> > The u-boot is standard stock u-boot pulled from the
> recent git,
> > no special configuration involved.
>=20
>=20
> Are you seeing this message when you run ethernet in
> u-boot?
>=20
> "Speed: 1000, full duplex, fiber mode"

I have this weird problem whereupon I assume something and then keep
believing it's true. So not, I'm not seeing this message. :)

There are two interfaces attached to that phy, one is normal RJ45, the
other is an uTCA backplane (it has only two pairs, so I assumed it must
be operating in fiber mode). Uboot works perfectly well with both and
prints the same messages.

That's the example printout from u-boot (eTSEC1 is connected to backpla=
ne)

> dhcp
Speed: 1000, full duplex
BOOTP broadcast 1
DHCP client bound to address 192.168.1.202
Using eTSEC1 device

>=20
> You could probably change to use a fixed link by removing
> the
> phy-handle property from your ethernet device node, and
> adding:
> "fixed-link=3D<0 1000 1 0 0>".=A0 If that works,
> then the issue is that
> Linux is breaking something when it connects. It might be
> good enough
> for you to use fixed-link, though it would be good to
> actually find
> out what's going wrong with the PHY driver.
>=20

I'll try this out now.

I'm trying to obtain a data sheet for the device, but had not succeeded
in it just yet.

