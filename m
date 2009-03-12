From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 17:13:54 -0700
Message-ID: <20090311171354.04c7a63d@nehalam>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
	<20090310211841.388619ca@nehalam>
	<20090311084430.GU425@pengutronix.de>
	<20090311.014957.117115597.davem@davemloft.net>
	<49B82566.3070909@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, s.hauer@pengutronix.de,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36973 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbZCLAOD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 20:14:03 -0400
In-Reply-To: <49B82566.3070909@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Mar 2009 21:56:06 +0100
Christer Weinigel <christer@weinigel.se> wrote:

> David Miller wrote:
>=20
> > From: Sascha Hauer <s.hauer@pengutronix.de>
> > Date: Wed, 11 Mar 2009 09:44:30 +0100
>=20
>  > > [some code to pass the MAC address as module parameters]
>=20
> > Please remove this code.  If we let you do it, we have to let every=
one
> > else do it too, and that's something we don't want to do.
> >=20
> > There are other ways you can handle this, for example have your boa=
rd
> > firmware properly program the MAC address into the card at power-on=
,
> > and then have the driver here look in the MAC address registers to =
see
> > if a valid ethernet address has been left there.
>=20
>=20
> It's still a pain to have to do this.  Many embedded systems that I h=
ave=20
> seen have a bootloader which I can't modify to do that, but the=20
> bootloader allows me to save the kernel command line into some kind o=
f=20
> volatile storage.  S=C3=A5 being able to set the MAC address with a:
>=20
>      setenv cmdline foo.hwaddr=3D00:de:ad:be:ef:ed
>=20
> is very nice because it allows me to use a NFS root without having to=
=20
> jump through hoops with initrds an such.
>=20
> Actually, I wish we had a generic way of doing that, so that could se=
t=20
> the mac address of any ethernet interface from the kernel command in =
a=20
> nice and supported way.
>=20
>    /Christer

The problem is that usually users end up with all devices with the
same address, unless there is some other procedure to hand out addresse=
s
during configuration. That is why the random_ether_addr is safer.
