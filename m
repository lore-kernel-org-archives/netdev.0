From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 05/14] ethtool: Expand documentation of struct
 ethtool_eeprom
Date: Wed, 12 Feb 2014 22:14:17 +0000
Message-ID: <1392243257.15615.9.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SoYsFFYAnEVWS2NH3Y6P"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52785 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754333AbaBLWOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:24 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SoYsFFYAnEVWS2NH3Y6P
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 441bd31..d5a0d20 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -231,12 +231,29 @@ struct ethtool_regs {
 	__u8	data[0];
 };
=20
-/* for passing EEPROM chunks */
+/**
+ * struct ethtool_eeprom - EEPROM dump
+ * @cmd: Command number =3D %ETHTOOL_GEEPROM, %ETHTOOL_GMODULEEEPROM or
+ *	%ETHTOOL_SEEPROM
+ * @magic: A 'magic cookie' value to guard against accidental changes.
+ *	The value passed in to %ETHTOOL_SEEPROM must match the value
+ *	returned by %ETHTOOL_GEEPROM for the same device.  This is
+ *	unused when @cmd is %ETHTOOL_GMODULEEEPROM.
+ * @offset: Offset within the EEPROM to begin reading/writing, in bytes
+ * @len: On entry, number of bytes to read/write.  On successful
+ *	return, number of bytes actually read/written.  In case of
+ *	error, this may indicate at what point the error occurred.
+ * @data: Buffer to read/write from
+ *
+ * Users may use %ETHTOOL_GDRVINFO or %ETHTOOL_GMODULEINFO to find
+ * the length of an on-board or module EEPROM, respectively.  They
+ * must allocate the buffer immediately following this structure.
+ */
 struct ethtool_eeprom {
 	__u32	cmd;
 	__u32	magic;
-	__u32	offset; /* in bytes */
-	__u32	len; /* in bytes */
+	__u32	offset;
+	__u32	len;
 	__u8	data[0];
 };
=20


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-SoYsFFYAnEVWS2NH3Y6P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyOee/yOyVhhEJAQqZKw//Z6vjzwd7GFfcP6RBN5CC0qgew77z/D88
U6tTqEeLKwcaIVlQBJu4FpUSLDrCL3WzQSnWQl4sGdHBTqX1MxJuX/yZMZfHe3h6
6j2+X1On01Z4AsS7BXLhtAm41AbEjuQZnmvO3YCo2ueV1Inh/h9FO+dVgfJJCr7V
F/w0ES9pO62Cm9BQ3HFfeZqG5jXJvTtvj0Q5c8yhRILnyV3pcOlJP2PIs+Xf6bwX
j9jQT69LeFXglY7LH+YokYHgd87gVLEh2qE+Yay8QPBg4ZZkrqDAaBsl17AXiZnc
k70UGcsZmbKIKWPNd5rcGCZ903kvtxjFjhbf0SAnRV7HFcTxzwAqUR7YlRMCdRuc
PWJfxmcC97gpiue5/YEmaFGWHHERBduaZkvVdUKhSYLzcGZGKUMKu7x5Qlddl27Z
GzXSJqHMNMh72Os/OdehJRGraGP82h3N7FQuutsNt2OytzDqNYYievoMERKfZFxI
7JWow5opVkiargnMlc5aRnXdTHrSQLmF92oVL65pSiZha1zHI+yBEh5r7ehxZsPC
X8+24PoBGq8wmKHe+Iar1Z4N/lCq5qEGxZ2/b+WWwZipLTTBH/kA3+KxVF+sD6ze
T2twDIRBVVMvWPJpPiDyzRyVjPzg2f0fmCQxErUsV+bu+S12kP7qocsyDjdiAOux
9sPDqjg3T1M=
=UDG4
-----END PGP SIGNATURE-----

--=-SoYsFFYAnEVWS2NH3Y6P--
