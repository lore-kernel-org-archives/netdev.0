From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 09/14] ethtool: Expand documentation of struct
 ethtool_test
Date: Wed, 12 Feb 2014 22:14:38 +0000
Message-ID: <1392243278.15615.13.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zLgRsi7tCZfmSy4k9ygI"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52798 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754534AbaBLWOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:45 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zLgRsi7tCZfmSy4k9ygI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e726340d..f246f37 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -575,12 +575,25 @@ enum ethtool_test_flags {
 	ETH_TEST_FL_EXTERNAL_LB_DONE	=3D (1 << 3),
 };
=20
-/* for requesting NIC test and getting results*/
+/**
+ * struct ethtool_test - device self-test invocation
+ * @cmd: Command number =3D %ETHTOOL_TEST
+ * @flags: A bitmask of flags from &enum ethtool_test_flags.  Some
+ *	flags may be set by the user on entry; others may be set by
+ *	the driver on return.
+ * @len: On return, the number of test results
+ * @data: Array of test results
+ *
+ * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
+ * number of test results that will be returned.  They must allocate a
+ * buffer of the appropriate size (8 * number of results) immediately
+ * following this structure.
+ */
 struct ethtool_test {
-	__u32	cmd;		/* ETHTOOL_TEST */
-	__u32	flags;		/* ETH_TEST_FL_xxx */
+	__u32	cmd;
+	__u32	flags;
 	__u32	reserved;
-	__u32	len;		/* result length, in number of u64 elements */
+	__u32	len;
 	__u64	data[0];
 };
=20


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-zLgRsi7tCZfmSy4k9ygI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyTue/yOyVhhEJAQrykA/+JVwR40s1UkUCLdkIVYdDCAKnZmSncxBp
Q5c3YOj04FFY1npa18ostn4kvE0JzOdTJ7hDXxbGP5KCZE2Hz3tD2BWvxF5QK8P4
JOp6AUbxHCjxlvAoptzScqemgpquqAXXPdydNZsrIPlU7oBrPLiC9BFhfPtZfSSS
jBBHg8AYdDLXfZCzjhtshoPswrB/Hfar0L9VnVmi9hlc4hFrzAKpkTCo7k5Xj5It
yk0dp3stM1fGxrvgy7myf4et6gTk4KffqxrLhxyndIoy/Fij2HjS/ACOUKP+Tgiw
KJ8NvYPwoRQMolOTXu+X9SvoZahqmDD5mx7++0ZWd7krgtg5pQAjtJtO3RZNyMDv
GwrDtf7KgEk2k0F8ORAUYWmBdxSp2FXLlh3hvxbN1prHI97pq7GVjqqOap9AHnEW
yWY/lOMYUifBmWNWwdouRQrY1ezSLf63bT+O7QajNiR8/0Ul1RF6Li3+A1cyl2qH
2Ziy4JXaAczM4kST0bS0kJsvxZD3LxVd/1zv8UfUgYFMuR0vGiId6VvwWjAKi4Sh
gdHwE+QRhgjwDvaoiDWli+y5SnS4lVC0H3und3ibdZFCXQ4Vw3nRDmp2ew6fRK7R
JspGLQEhfiBF2atrO5Wh9h8TaOgtKgku2CvoWeG7UQYGcH96KW+D27v9WTK+iDi+
qye+PRSV9bo=
=c8Pq
-----END PGP SIGNATURE-----

--=-zLgRsi7tCZfmSy4k9ygI--
