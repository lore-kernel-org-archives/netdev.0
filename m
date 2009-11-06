From: Gregory Haskins <ghaskins@novell.com>
Subject: [ANNOUNCE] AlacrityVM v0.2 is released
Date: Thu, 05 Nov 2009 21:44:12 -0500
Message-ID: <4AF38D7C.40604@novell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig28E20E2114CB3B191A4FEB5A"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: "alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	alacrityvm-users@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755606AbZKFCoV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig28E20E2114CB3B191A4FEB5A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

We (the AlacrityVM team) are pleased to announce the availability of the
v0.2 release.  There are numerous tweaks, fixes, and features that we
have added since the v0.1 days.  Here are a few of the key highlights.

*) VENET support:
   *) zero-copy transmits (guest memory is paged directly to the
physical adapter on the host, where applicable)
   *) "SAR offloading" (essentially bi-directional GSO with "64k MTU")
   *) pre-mapped descriptors to reduce latency
   *) pre-loading of mmu context to reduce latency

*) shm-signal's are now routable (e.g. future MQ support)

*) vbus is optionally managed in its entirely from the rebundled qemu
   *) "-net venet-tap" will fully initialize the interface
internally..no more scripting!

*) vbus components are automatically reaped when the guest exits, even
if the exit is not clean.

We will update the performance numbers ASAP and announce any changes.
For further details, please visit our wiki:

http://developer.novell.com/wiki/index.php/AlacrityVM

Kind Regards,
-Greg


--------------enig28E20E2114CB3B191A4FEB5A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrzjXwACgkQP5K2CMvXmqHLDQCfZhxj5nscvq8nWmYamuMcLZrO
yZ0An27Wd9gNQZdNDP3tEiJ1nJFeZjF4
=qEZW
-----END PGP SIGNATURE-----

--------------enig28E20E2114CB3B191A4FEB5A--
