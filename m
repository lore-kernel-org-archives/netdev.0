From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 11/14] ethtool: Expand documentation of struct
 ethtool_perm_addr
Date: Wed, 12 Feb 2014 22:14:48 +0000
Message-ID: <1392243288.15615.15.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dhWiugpJjCHa+qyMo/JZ"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52806 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbaBLWO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:56 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dhWiugpJjCHa+qyMo/JZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e96aec0..79be416 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -614,8 +614,19 @@ struct ethtool_stats {
 	__u64	data[0];
 };
=20
+/**
+ * struct ethtool_perm_addr - permanent hardware address
+ * @cmd: Command number =3D %ETHTOOL_GPERMADDR
+ * @size: On entry, the size of the buffer.  On return, the size of the
+ *	address.  The command fails if the buffer is too small.
+ * @data: Buffer for the address
+ *
+ * Users must allocate the buffer immediately following this structure.
+ * A buffer size of %MAX_ADDR_LEN should be sufficient for any address
+ * type.
+ */
 struct ethtool_perm_addr {
-	__u32	cmd;		/* ETHTOOL_GPERMADDR */
+	__u32	cmd;
 	__u32	size;
 	__u8	data[0];
 };


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-dhWiugpJjCHa+qyMo/JZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyWOe/yOyVhhEJAQrc5Q//dgliPS1ikkfrlP4vNHPxF40evZcv/dxk
0qp6PC5hpu50nFDXhikrTFFIQodRjzd1d3DCjneduuD6Zg/oOIuO88EH4UcSgJFW
sBRHsGETV/kMxbRYbF3NuuVPsc6a2dM+Rpqrs534ICKvatwt0ys4arx3hre5jaBC
ZULgtLpO54QuVc1f8QZhjSmgfmD1QLNY3xlojw6DLk2CnmC7rVCnzj2LJdZpZne7
HciQjjGg45SEDRxfXDbI0RVSIQYWCKf4seT19Q/Rq4dK8DLTqD40AtQ1WIoHWfpK
Axma3oTo99coJxEVInkyUfAImXnend9OknhduYs51yjt7jhhCoNqBRgCFuvkPjcp
u9v5W5GvvJeRtBIaSP4sTIb/a/EqsLLjcoZdU/vpB2paQdrJsJX2pFZfEQqewitb
H8Vriax0nXiUGNoRKzwdZIqX3Wazn5FUgOteFdEJ1ZigqEKvVOA2bImrOQ0bHeEg
TnBzEul5rcvMHiFSN2ZeFkVII8vtzwFEBrEOfGZLE2orlz4iKykPATP2pIZ09Q5g
h8rF6sH/JIgOYY2R1CjxLTEu8h+W3dcR3PvxfbLZXSJd27H+/KNR+0VBuR8wiisD
MY91AC5Cf3NpfeTys1AvEC6VIsRt3b3guqFT/uksNne086e+VnbYJeQTbugQyscg
U+ZCaTMVdzw=
=8wze
-----END PGP SIGNATURE-----

--=-dhWiugpJjCHa+qyMo/JZ--
