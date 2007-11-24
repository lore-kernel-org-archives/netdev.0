From: Ian Kumlien <pomac@vapor.com>
Subject: [SKY2] Problems (2.6.24-rc3-git1)
Date: Sat, 24 Nov 2007 17:23:51 +0100
Message-ID: <1195921431.8378.5.camel@localhost>
References: <1191372129.26233.12.camel@localhost>
	 <20071002180209.47c350a3@freepuppy.rosehill>
	 <1191375274.26233.17.camel@localhost>
	 <20071002215914.13d1e8cf@freepuppy.rosehill>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-B2cTkVzA2dWPV0yY7J+n"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vapor.com ([85.114.133.49]:56119 "EHLO mail.vapor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbXKXQ6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2007 11:58:04 -0500
In-Reply-To: <20071002215914.13d1e8cf@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B2cTkVzA2dWPV0yY7J+n
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

A little while ago, something went horribly wrong.

I could still use my mouse and the desktop was still alive more or
less... everything using networking was dead AND the keyboard was
dead... So i composed commands using existing text on the screen.

The device:
sky2 0000:02:00.0: v1.20 addr 0xdbffc000 irq 17 Yukon-EC (0xb6) rev 2
sky2 0000:02:00.0: PCI Express Advanced Error Reporting not configured or M=
MCONFIG problem?
sky2 0000:02:00.0: No interrupt generated using MSI, switching to INTx mode=
.
sky2 eth0: addr 00:15:f2:aa:8b:3e

=46rom dmesg:
sky2 eth0: hung mac 124:39 fifo 195 (185:180)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 442 .. 461 report=3D442 done=3D442

And it continues until i press the reset button.


--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-B2cTkVzA2dWPV0yY7J+n
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7-ecc0.1.6 (GNU/Linux)

iD8DBQBHSFAU7F3Euyc51N8RAtzVAJ4klY24N/ebyN5fwl7FUtrhQSAXoACfSHad
0muKTN+6bK7Nkf+UEN9GHzE=
=wNcH
-----END PGP SIGNATURE-----

--=-B2cTkVzA2dWPV0yY7J+n--

