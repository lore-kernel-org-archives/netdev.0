From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 20 Nov 2006 10:02:02 -0800
Message-ID: <20061120100202.6a79e382@freekitty>
References: <20061119203050.GD29736@osprey.hogchain.net>
	<200611200057.45274.arnd@arndb.de>
	<45614769.4020005@redhat.com>
	<200611201322.00495.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966310AbWKTSGM@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200611201322.00495.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 13:21:59 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> On Monday 20 November 2006 07:12, Chris Snook wrote:
> > >=20
> > > Any reason why you can't use generic_mii_ioctl?
> >=20
> > I decided to mostly leave this code alone, in the hope that we coul=
d=20
> > just rip out MII support entirely and nobody would mind. =C2=A0What=
 do you think?
> >=20
>=20
> Normally, I think you should just implement mdio_read/mdio_write func=
tions
> and then use all the helpers from drivers/net/mii.c to implement mii_=
ioctl
> and other functions like ethtool_gset.
>=20
> 	Arnd <><
>=20

Using common MII code is good, but one problem with the existing MII co=
de is that
it doesn't work when device is down. This makes it impossible to set sp=
eed/duplex
before device comes up.

--=20
Stephen Hemminger <shemminger@osdl.org>
