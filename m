From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 19:37:43 +0000
Message-ID: <1322249863.2839.375.camel@deadeye>
References: <1322230071.2839.337.camel@deadeye>
	 <20111125.132220.150546128040363058.davem@davemloft.net>
	 <1322246442.2839.358.camel@deadeye>
	 <20111125.135022.2150651060225144120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PanLydwhnfT6T+p98Nzo"
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60603 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445Ab1KYTh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 14:37:58 -0500
In-Reply-To: <20111125.135022.2150651060225144120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PanLydwhnfT6T+p98Nzo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-25 at 13:50 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Fri, 25 Nov 2011 18:40:42 +0000
>=20
> > On Fri, 2011-11-25 at 13:22 -0500, David Miller wrote:
> >> Try allmodconfig for yourself.
> >=20
> > OK, on x86_64, this does end up with PHYLIB=3Dy but only because
> > NET_DSA=3Dy.  And I don't believe NET_DSA is appropriate for a distro
> > kernel.
>=20
> Do you think we can modularize the NET_DSA reference somehow?

Maybe, but I just don't care about DSA.  It requires platform data to
work, so AFAICS it's only useful in a custom kernel for some platform
that has one of the supported chips.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-PanLydwhnfT6T+p98Nzo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATs/uh+e/yOyVhhEJAQrSBBAAmyCrSgyQibSV+PbdaAvcLt6Kadf1O3Kd
fZTJy98bihUwX4ZVn/gg51w9MZyTTBFZw/7n08GcRC/ROul6wlRrW6ZI8W+HukRF
ovK+oDr/wM8mtKLKMwI4w2ZEYTVmKjv1SOFl6qHA8VXXx1oPYESjwlMdv+gxL6mA
xKLezID6RdOAPexkBY5ORmOnD7miYUvoJFIBwnbJjv8UoScgJ/gwJv75PIq1wOt9
Xm/b9B3FCH1u6ERSpxcLEJjJRqhjdX3ZKBqVT5/iCAZRLH1OeWyiy3I0OGpZno/f
F8YUnuhOSA1XPJtW+Snl9HHS+0G8KZwQP/ybMzZssI+xT4b+Og4pPq7LwYBGwSzB
E5rD/p0QKYwcLUngcILbfwvC1YcYzrGE9iSsPgqMQAoLyEjpGAq9cCsggGpzPjbt
btymBftvZJ4Rhv67rFlvTFYwqTadl2CxtQTuMdZ0eb4tkCK8JBwMqlgwDBGEFk99
xujFDa8lW5mIpMiagoewjoTPyw+GDQSItOBvBv5+VxLiJcdropNCCmQZlvys9aqm
y4CgL28i2Ki4S+QEUB5tv+l5KYi5p8Z2PbcZUGqxEYNFPKur22n225DtzvdwHrLG
w1uOWireZlEW9v+1ar9nEWOv9gEJmTrIWZveFlzwghapfn9wP5YziL7fuCSQh2hz
gSh8QtefXJg=
=V2jB
-----END PGP SIGNATURE-----

--=-PanLydwhnfT6T+p98Nzo--
