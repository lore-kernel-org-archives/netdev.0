From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 04/14] ethtool: Expand documentation of struct
 ethtool_regs
Date: Wed, 12 Feb 2014 22:14:13 +0000
Message-ID: <1392243253.15615.8.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5OhdzbrYZIo6kAbQCjug"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52782 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754333AbaBLWOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:20 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5OhdzbrYZIo6kAbQCjug
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 15a42de..441bd31 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -209,11 +209,25 @@ struct ethtool_value {
 	__u32	data;
 };
=20
-/* for passing big chunks of data */
+/**
+ * struct ethtool_regs - hardware register dump
+ * @cmd: Command number =3D %ETHTOOL_GREGS
+ * @version: Dump format version.  This is driver-specific and may
+ *	distinguish different chips/revisions.  Drivers must use new
+ *	version numbers whenever the dump format changes in an
+ *	incompatible way.
+ * @len: On entry, the real length of @data.  On return, the number of
+ *	bytes used.
+ * @data: Buffer for the register dump
+ *
+ * Users should use %ETHTOOL_GDRVINFO to find the maximum length of
+ * a register dump for the interface.  They must allocate the buffer
+ * immediately following this structure.
+ */
 struct ethtool_regs {
 	__u32	cmd;
-	__u32	version; /* driver-specific, indicates different chips/revs */
-	__u32	len; /* bytes */
+	__u32	version;
+	__u32	len;
 	__u8	data[0];
 };
=20


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-5OhdzbrYZIo6kAbQCjug
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyNee/yOyVhhEJAQp1Qg/8CoFTLp0rul0Te/HeOHchxBk8JCfCYfVm
yepJl/4DaK/uPGhe8ZMM9KBliRpE1lzcE4j7KaSc6R7T86A0Z7EXWlVsO3NiXzSk
o6KP5+ee+rVZ/SF+4jzlq4G2yGdtqSAE5ciUMKJ3DBmsNw1pzsk5cgkSSfjcV6Ni
sQ03K9u5y03YsSsa78xHnErrGmFB0HJG7uLR6CB0QOAE4WNcp2VQfUEwNyQs41iI
8lTqxL/Rq/N3ehpEaeLdWNVPW8hjsL/cyhei6XQMeINPF8XPJP9fXGAjUJIGyCYs
I/iSilSEfwH2LBxgC0XwsLL10RbfbBvJhqwNUty6EICd7HSZY59m2QclgBwolFiI
YDnuTzccup9psD5B13adZnJwo9BfxVAQR+XAxxrwLr1s5Jg83y/TSr6TlsEwfIru
YhDgduTX4kcReg5fmro0DMs9Q8E0j5aIOPOsF/y7pV/7FmvNdveVENfFdq4P7cnk
fqLKkJP0hSSslGlAkFohd3p/JFTB0oIRy/V7PhybnNhaJfz0s6wUvQYXAXcuH6ig
lj0ooETdzGA0k+q0IIpuA41DaTNDQVc5BPaz4iXrmTMeC6zSzPchAbyHvu1bm//D
4V+XKoYCCqyZ9zKFaVgbxzUlQRWacA4SwmOtE4dHAXK3Rh+XfDZU0IUDNC0UxHP2
h+gsiAtLTiM=
=iStP
-----END PGP SIGNATURE-----

--=-5OhdzbrYZIo6kAbQCjug--
