From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: fix for 82599 erratum on Header Splitting
Date: Fri, 04 Mar 2011 23:51:07 -0800
Message-ID: <1299311467.26413.31.camel@jtkirshe-MOBL1>
References: <1299308767-28735-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110305074419.GA19596@suse.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-zukfJ9MKHKboO02ECjRY"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"stable@kernel.org" <stable@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12581 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982Ab1CEHyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 02:54:45 -0500
In-Reply-To: <20110305074419.GA19596@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zukfJ9MKHKboO02ECjRY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-03-04 at 23:44 -0800, Greg KH wrote:
> On Fri, Mar 04, 2011 at 11:06:07PM -0800, Jeff Kirsher wrote:
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> >=20
> > We have found a hardware erratum on 82599 hardware that can lead to
> > unpredictable behavior when Header Splitting mode is enabled.  So
> > we are no longer enabling this feature on affected hardware.
> >=20
> > Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> > Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ixgbe/ixgbe_main.c |    4 ++++
>=20
> I'm confused, why did you just send this patch to me?
>=20
> What am I supposed to do with it?
>=20
> greg k-h

This is the fix for ixgbe (that Ben and others pointed out) which has
been accepted into Linus's tree which did not apply to stable-2.6.32
tree.  This is the updated patch that apply's to the stable-2.6.32 tree.

--=-zukfJ9MKHKboO02ECjRY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNcetrAAoJECTsCADr/EWULXkIAK7PVWXN4Fskpn6Nh+4j21mc
MHGf0iDZwIWQ1aWdJYysgPRcRw3cI2ZZSIn+8JWdiIqj/AbUhvSSfbFUH7UcJjiH
2IY50rksJOq1fwvFmD1SbzjpZTmkGaLPScZ5QJWI7TUdhMpY9SXNRm93+wSF8bWc
eM9K9IkGHokcDeVSZ5t9ToXY1hYonsrpPQQJ6HFJ8wTQdB2ObpqSHFpy3B3Eza7C
UcMLx4RwkeixZXhX7u4cZI2DKleb7yQevGkqFtA7WBtm7JoVdDiU79rSRIq8tO5G
W3qbTqvCIP4zK9bkkxoU97433NzVYb70f1LRsbyrLxpQZk/z+RyHSPah5W90NXU=
=j174
-----END PGP SIGNATURE-----

--=-zukfJ9MKHKboO02ECjRY--

