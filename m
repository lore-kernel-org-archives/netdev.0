From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] ehea: add kexec support
Date: Wed, 31 Oct 2007 09:50:36 +1100
Message-ID: <1193784636.32504.4.camel@concordia>
References: <200710261437.29117.ossthema@de.ibm.com>
	 <1193610737.9637.1.camel@concordia>
	 <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CmVz5gAZys5+6MeUC5iC"
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, ossthema@linux.vnet.ibm.com,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34292 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbXJ3Wui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 18:50:38 -0400
In-Reply-To: <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CmVz5gAZys5+6MeUC5iC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Tue, 2007-10-30 at 09:39 +0100, Christoph Raisch wrote:
>=20
> Michael Ellerman <michael@ellerman.id.au> wrote on 28.10.2007 23:32:17:
> >
> >
> > How do you plan to support kdump?
> >
>=20
> When kexec is fully supported kdump should work out of the box
> as for any other ethernet card (if you load the right eth driver).
> There's nothing specific to kdump you have to handle in
> ethernet device drivers.
> Hope I didn't miss anything here...

Perhaps. When we kdump the kernel does not call the reboot notifiers, so
the code Jan-Bernd just added won't get called. So the eHEA resources
won't be freed. When the kdump kernel tries to load the eHEA driver what
will happen?

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-CmVz5gAZys5+6MeUC5iC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJ7U8dSjSd0sB4dIRAubzAJ0eYG2bv6FPefxuha0m4gn4vgoEwACgpplu
F2/eB6tWnkcAvOlO8I750yI=
=9k6M
-----END PGP SIGNATURE-----

--=-CmVz5gAZys5+6MeUC5iC--

