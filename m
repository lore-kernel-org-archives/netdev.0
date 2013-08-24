From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/2] Documentation/networking/: Update Intel wired
 LAN driver documentation
Date: Fri, 23 Aug 2013 17:09:40 -0700
Message-ID: <1377302980.3939.91.camel@jtkirshe-mobl>
References: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377262419.3364.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vs+XiI7uBYz7MoDMqE5t"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:51167 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab3HXAJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 20:09:42 -0400
In-Reply-To: <1377262419.3364.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vs+XiI7uBYz7MoDMqE5t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-08-23 at 13:53 +0100, Ben Hutchings wrote:
> On Fri, 2013-08-23 at 05:29 -0700, Jeff Kirsher wrote:
> > Updates the documentation to the Intel wired LAN drivers.
>=20
> Except e100.txt which seems to be moving backward in time:
>=20
> [...]
> > --- a/Documentation/networking/e100.txt
> > +++ b/Documentation/networking/e100.txt
> > @@ -1,7 +1,7 @@
> >  Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
> >  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > =20
> > -November 15, 2005
> > +March 15, 2011
> > =20
> >  Contents
> >  =3D=3D=3D=3D=3D=3D=3D=3D
> > @@ -94,8 +94,8 @@ Additional Configurations
> > =20
> >    Configuring a network driver to load properly when the system is sta=
rted is
> >    distribution dependent. Typically, the configuration process involve=
s adding
> > -  an alias line to /etc/modprobe.d/*.conf as well as editing other sys=
tem
> > -  startup scripts and/or configuration files.  Many popular Linux
> > +  an alias line to /etc/modules.conf or /etc/modprobe.conf as well as =
editing
>=20
> Reverting this fix:
>=20
> commit 970e2486492aa1eb47a436a5a4c81e92558986a9
> Author: Lucas De Marchi <lucas.demarchi@profusion.mobi>
> Date:   Fri Mar 30 13:37:16 2012 -0700
>=20
>     Documentation: remove references to /etc/modprobe.conf
>=20
> [...]
> >    Enabling Wake on LAN* (WoL)
> >    ---------------------------
> > -  WoL is provided through the ethtool* utility.  For instructions on e=
nabling
> > -  WoL with ethtool, refer to the ethtool man page.
> > +  WoL is provided through the ethtool* utility. The ethtool utility is=
 included
> > +  with Red Hat* 8.0. For other Linux distributions, download and insta=
ll
> [...]
>=20
> And part of this one:
>=20
> commit 68f20d948c86bd6bbc075052f6b6c45b8f56957e
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri Dec 17 12:14:34 2010 +0000
>=20
>     Documentation/networking: Update Intel Wired LAN docs
>=20
> Mentioning a 2002 distribution is completely pointless.
>=20
> Ben.
>=20

Thanks Ben, I will drop all the e100.txt changes at this point.  The
driver has little to no changes in the last couple of years, so the
documentation should not be changing.

I will re-spin with a v2.

--=-vs+XiI7uBYz7MoDMqE5t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSF/nEAAoJEOVv75VaS+3OLfMP/1w/FuDX/Zmq9San1zh/j/GX
xKBjRaOJ1baKcbAFvbeLwKbZ1MC5AK9qoQyLN+xMzEl+NRBjaZoGkBDCxI249klI
efH1T6ZphS1gbiOhPlrMINzT0tBUATSX/R+5wURGzTG/GmRJR04rKEcmyMpNtx1J
KShZm2b7vjmXbL/BArtjQbp8FUzT4IX10XVfEr9FIhCJA00A5eHZwAMzuvbMm2sZ
W0VMlJYOp67Hp8dr3GDaFmsK8NT32L7cCCe4ffLCdOIgRjgKy4DAMAdYKO3dN+4U
ta7ZBbShsdTunf7gP3OfXZCus1yT+RJilW6S7lAKWz8kJjADbec/ER8iAFc71B9e
ycdN3LR2xPlprtuDt+sdTRIDeOLL+Bn26LOvz9rudMlqAnCfmmfcpOfY7eG9/LYm
gsEOoAuOm5sb6TWEUPLNDYBnlPZQHcUnXtrXF9+kZiXhyWQ/i2itpnBMGO6jtKiE
FgndOy/lnVtsZBvXioj6m1VDpqT4nRdVPkocoaieZ2Mz1uU7omTrWJ+LEpWHH+Mi
WbWC0vyfElaHKJ7DXDfq+I5q9eHSRk9m1zkV8v16PXrhO1m/1n8aBRSAA7xzQi3W
mThtkKEL35OsMBSMuMnRWDBEuardDpKir3nZJW8PfvF0hshhvTlg+719CBMvGmOi
ap/BssFRk9SRoLICS9mb
=G87E
-----END PGP SIGNATURE-----

--=-vs+XiI7uBYz7MoDMqE5t--
