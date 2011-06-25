From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 11:02:42 -0700
Message-ID: <1309024963.2454.85.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <201106251803.53416.arnd@arndb.de>
	 <20110625161227.GJ23234@n2100.arm.linux.org.uk>
	 <201106251859.38963.arnd@arndb.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-I6mZ/TXxoQUEe7DY6MD/"
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sriram <srk@ti.com>, Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27644 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953Ab1FYSCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 14:02:44 -0400
In-Reply-To: <201106251859.38963.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-I6mZ/TXxoQUEe7DY6MD/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-06-25 at 09:59 -0700, Arnd Bergmann wrote:
>=20
> > ether1 is 82586, so presumably that should be Intel subdirectory.
>=20
> Yes, according to the new layout, it should at least live together
> with the other 82586-based drivers (eexpress.c, ni52.c, sun3_82586.c),
> which could be either a directory for all of these, or the
> generic intel directory.=20

My personal preference is that these drivers that were not created by
Intel or maintained by Intel, not be in the Intel sub-directory.

While many of the drivers were organized in a layout that matches
drivers/net/ethernet/<company>, I tried to organize the drivers in the
most logical way possible (i.e. 8390/ all the drivers that used the 8390
shared files).

I do like all the suggestions made, except for the suggestion to move
eexpress.c, eepro.c, sun3_82596.c, etc. in to the intel sub-directory.
I am open to suggestions on a way to better to organize these drivers
that use an Intel part but were created and maintained by someone else.

--=-I6mZ/TXxoQUEe7DY6MD/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEbBAABAgAGBQJOBiLCAAoJECTsCADr/EWUcr4H93ZOx3EwzTmF5s2Rvqd8AsT0
ffpO15Ex6wX/WgobLWr5WpA09QKPzF++coQXNSG/EXqEt1ZoL0YXJEU9Bv0+Qa4P
R0Hdy13zNDCyJyjNgeF7bKs+HE9c4ik9cpUwk64LpXFeG93SvhTlfeHXc6NcYYez
5+7Z1x3DmkAXoFIUPYF1L6sgGvYKgodyB16zRcKhOmSOJa+KJv13eQoP68xzPGsc
gtOQUvzmIW2flx1TuiHLbLUK0VZIRbuJYOyCaCXoXhkKQBIktVhKuju43qBIAIRS
6p19IcXnyj3YqyaslKTVkQgd0IiTc9Y26pEhBABUBP+FwI0tv3+hg33JYLke8A==
=tB5x
-----END PGP SIGNATURE-----

--=-I6mZ/TXxoQUEe7DY6MD/--

