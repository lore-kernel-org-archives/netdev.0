From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3
 installer
Date: Sat, 19 Nov 2011 19:37:16 +0000
Message-ID: <1321731436.2885.151.camel@deadeye>
References: <20111018142056.GF29261@torres.zugschlus.de>
	 <1319084914.23980.96.camel@deadeye>
	 <20111021090046.GA13930@torres.zugschlus.de>
	 <20111021090811.GA5993@torres.zugschlus.de>
	 <1319199579.2918.42.camel@deadeye>
	 <20111024212409.GA29764@mcarlson.broadcom.com>
	 <1319500074.31243.47.camel@deadeye>
	 <20111026002032.GA31575@mcarlson.broadcom.com>
	 <1319614904.11727.17.camel@deadeye>
	 <20111118195435.GA31807@mcarlson.broadcom.com>
	 <20111119184536.GE4187@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rcmkbwIvzzoCyQbHKDEl"
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: Marc Haber <mh+debian-bugs@zugschlus.de>, 645308@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58678 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752472Ab1KSThn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2011 14:37:43 -0500
In-Reply-To: <20111119184536.GE4187@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rcmkbwIvzzoCyQbHKDEl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-11-19 at 19:45 +0100, Marc Haber wrote:
> On Fri, Nov 18, 2011 at 11:54:35AM -0800, Matt Carlson wrote:
> > I think I misspoke earlier.  The commit I mentioned above fixes a probl=
em
> > introduced in an earlier patch.  (commit ID
> > d2394e6bb1aa636f3bd142cb6f7845a4332514b5, entitled
> > "tg3: Always turn on APE features in mac_mode reg")  So the fact that
> > 2.6.32-35 works and 2.6.32-36 doesn't means you applied the problematic
> > patch that had the bug, but you didn't apply the above fix to correct i=
t.
>=20
> I can try a fixed kernel, but I don't understand the way Debian builds
> its kernels. I can
>=20
> (a) download a Debian kernel source package, apply
> d2394e6bb1aa636f3bd142cb6f7845a4332514b5 and go the make; make install
> way or
> (b) wait for a kernel deb from Ben.
>=20
> If (a) is expected to give reasonable results, I can do that.

I'm not going to build a complete new package myself, as you can easily
do that with the debian/bin/test-patches script in the source package.
But I can provide you with a rebuilt tg3.ko so you can test just that
change in the installer like you did previously.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-rcmkbwIvzzoCyQbHKDEl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATsgFbOe/yOyVhhEJAQrI+BAAhLk4vPtId4cla37xf0VfLDnukY3b8LPw
MhQl8VguhxjBkgcUj3rZu+GQ1OaUpTw+x2L6xIT7nn1eFBkGa769BlAqqnrCSQo2
r/78o8Y0hG2c0GpLNDOvaGSGy0L26FrcRKw65HnF6QmySTz7GJVVzVjTlMdQWfnN
hcV++Q00HKJc7Bd6BQziZbwsNKM8GaqsK/CQWW/NaJLoNEkySDd+qDJAVb9YRxK4
s6tcrOTmCZA7uichd4Mdc3r/zvALP6wTWraWovn40DttKmH0LTfxKA7BOxwIDzD8
YHy0wjIF6UCzyL6ivVi9enk4F31JhAUWm1O3Q476tcZIViLuMH5UCqxAEQvAyrGA
mJjiPxy5CM5QPvXF3kR/usF/OkYSdDsYzxFoTY8ZqQL5eUv75lbBIpSzDZa022pK
xkOhAskFcCR2Ufg0RwSo79vCFm5EOVuXZLSKYV2qAaYQZF8j/i0Me5XthfdBR+6j
83IohNrWH0Q2yiC5QV1S4GUKmcREc0fNWYchh2ghJYSb8TCdgVN2zwn1OYKlDXcU
lalEP4BBkkwJeQfzQFDnAPU0OK9QscUcexbO9AQZTlIngM0FQ2Cbbnr9I/0+P4VH
8zE9Bz5xud6t76l7mJIaGqQsjdAWC4tyk2TkcUIWwLRlHod9EDwR+AGntEe9B4tp
viiqada2bXY=
=uSTd
-----END PGP SIGNATURE-----

--=-rcmkbwIvzzoCyQbHKDEl--
