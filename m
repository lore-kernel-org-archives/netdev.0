From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 20 Nov 2006 13:21:59 +0100
Message-ID: <200611201322.00495.arnd@arndb.de>
References: <20061119203050.GD29736@osprey.hogchain.net> <200611200057.45274.arnd@arndb.de> <45614769.4020005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	shemminger@osdl.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:35297 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S934114AbWKTMYX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 07:24:23 -0500
To: Chris Snook <csnook@redhat.com>
In-Reply-To: <45614769.4020005@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 20 November 2006 07:12, Chris Snook wrote:
> >=20
> > Any reason why you can't use generic_mii_ioctl?
>=20
> I decided to mostly leave this code alone, in the hope that we could=20
> just rip out MII support entirely and nobody would mind. =A0What do y=
ou think?
>=20

Normally, I think you should just implement mdio_read/mdio_write functi=
ons
and then use all the helpers from drivers/net/mii.c to implement mii_io=
ctl
and other functions like ethtool_gset.

	Arnd <><
