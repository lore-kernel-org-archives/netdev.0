From: Matt Domsch <Matt_Domsch@dell.com>
Subject: RFC: [0/3] PPP MPPE module
Date: Fri, 18 Jun 2004 11:10:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618161001.GE19269@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KuLpqunXa7jZSBt+"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--KuLpqunXa7jZSBt+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The pptpclient project at SourceForge has for several years maintained
the PPP MPPE (Microsoft Point-to-Point Encryption) ppp
compressor/decompressor module outside of the Linux kernel tree, as it
has needed arc4 and sha1 crypto routines which were not in-kernel
yet.  As they now are, I'd like to submit this code for review, and
when deemed ready, inclusion, into 2.6.x.

MPPE is a requirement for connecting Linux clients to Linux and
Microsoft PPTP (Point to Point Tunneling Protocol) servers.

Following two emails each contain patches.
1) Add ppp_mppe.c file to drivers/net
2) minimal touches to Makefile, KConfig, ppp_generic.c, and
include/linux/ppp-comp.h

I've asked that the pptpclient-devel list be opened to posts by
non-subscribers during this review period at least.

Feedback welcome.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--KuLpqunXa7jZSBt+
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFA0xPZIavu95Lw/AkRAi/nAJ4q2VsUchBS0q8W3ph2urgnXDeGWACdG1UV
JThHe9FACExvy1qLqAd6Vpc=
=GGep
-----END PGP SIGNATURE-----

--KuLpqunXa7jZSBt+--
