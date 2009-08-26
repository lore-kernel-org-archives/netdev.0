From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: AlacrityVM benchmark numbers updated
Date: Tue, 25 Aug 2009 21:01:22 -0400
Message-ID: <4A948962.7090909@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBAF2F37F4D27E7A7E6AA6204"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBAF2F37F4D27E7A7E6AA6204
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

We are pleased to announce the availability of the latest networking
benchmark numbers for AlacrityVM.  We've made several tweaks to the
original v0.1 release to improve performance.  The most notable is a
switch from get_user_pages to switch_mm+copy_[to/from]_user thanks to a
review suggestion from Michael Tsirkin (as well as his patch to
implement it).

This change alone accounted for freeing up an additional 1.2Gbps, which
is over 25% improvement from v0.1.  The previous numbers were 4560Gbps
before the change, and 5708Gbps after (for 1500mtu over 10GE).  This
moves us ever closer to the goal of native performance under virtualizati=
on.

These changes will be incorporated into the upcoming v0.2 release.  For
more details, please visit our project wiki:

http://developer.novell.com/wiki/index.php/AlacrityVM

Kind Regards,
-Greg


--------------enigBAF2F37F4D27E7A7E6AA6204
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqUiWIACgkQP5K2CMvXmqF9BwCdFTp8kstaf1ZPUuYdn3KnC1dH
XOYAnihscqZ86aDpLrA7yZ7gMYo3jjfP
=apF0
-----END PGP SIGNATURE-----

--------------enigBAF2F37F4D27E7A7E6AA6204--
