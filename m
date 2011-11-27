From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 6/8] dsa: Allow core and drivers to be built as
 modules
Date: Sun, 27 Nov 2011 22:39:24 +0000
Message-ID: <1322433564.7454.33.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
	 <1322267918.2839.388.camel@deadeye> <20111127191955.GU795@wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-l1TalImSs6mX55nFK+ki"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52325 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751514Ab1K0Wjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:39:31 -0500
In-Reply-To: <20111127191955.GU795@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-l1TalImSs6mX55nFK+ki
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-11-27 at 20:19 +0100, Lennert Buytenhek wrote:
> On Sat, Nov 26, 2011 at 12:38:38AM +0000, Ben Hutchings wrote:
>=20
> > Change the kconfig types to tristate and adjust the condition for
> > declaring net_device::dsa_ptr to allow for this.
> >=20
> > Adjust the makefile so that if NET_DSA_MV88E6123_61_65=3Dy and
> > NET_DSA_MV88E6131=3Dm or vice versa then both drivers are built-in.  We
> > could leave these options as bool and make NET_DSA_MV88E6XXX a
> > user-selected option, but that would break existing configurations.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
>=20
> Thanks for the patches!
>=20
> (While you're at it -- the switch chip drivers in net/dsa/ still
> ought to be moved to drivers/net/dsa/ or so -- feel like whipping up
> a patch for that?)

I agree.  Maybe.

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-l1TalImSs6mX55nFK+ki
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATtK8HOe/yOyVhhEJAQqw1xAAk4Juss3B7yE0Zji8h/+Y2rBYmTHL6c6y
BiVnMKzCBMXLTYwAkRM8k7fq/3bRiDGZpJ83TBU4hvVK4XZ4eefNp79VY7tlgADC
uBm9gpBTN7/WXpfL7pXTq94zyHYijH428uYucl7W27wYV+NZBq/Je8J+cmasuhab
+IQWhXcsXcMGYlGe6SGaAnx26llzBy53hXhagp8r6wq5LM8ScrlkxUVZqNoZJGAP
qM54ZyaoIuAitpXofo9eDgG99g13miomuZS5ZMAFJZMe3WpWDbfEN2znSUyS5w4D
2sFdfQNvRcbuXRffeYDBGxGAcj1QisbMu21WFkVSIQX9MbmcF+2aQwfacpChRcSP
frbSQaXSWvQ66xupMPvNKZj4bba53KpQx2KXBBhFBAafAUvd9ITSs/I/jb3rOMHH
BNKvt5xvQYk4inJqht+ZBkepnj/DYKAHH/szbVd7P/a+7E2IwXMNfjU5kkOhK7+a
ZxzGdjQtvDsewahL3zt9aQxjJ3sSs8m1Xm5HyndzZeMTAP5ukCX7llqbAxqauDac
FS5QjVJpUhApfURvSBAvgrmsdytmOA9EWkt+44qGyDOmJyuUXorzG+1Nh1YRR+Hr
KayEMtaVB9yFj7N5lpRIkbl3UVB/aD4MloGV1SCeMdfTUzbCRUzm98yldQQkYyZJ
lJSucaycUoc=
=HNUh
-----END PGP SIGNATURE-----

--=-l1TalImSs6mX55nFK+ki--
