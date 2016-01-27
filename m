From: =?UTF-8?B?SsO2cmc=?= Thalheim <joerg@higgsboson.tk>
Subject: [PATCH] tcp: Change reference to experimental CWND RFC.
Date: Wed, 27 Jan 2016 22:54:06 +0100
Message-ID: <20160127225406.18844cab@turingmachine>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/2ua/Pxdid21hc2mx.WW5Dvi"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.higgsboson.tk ([148.251.132.243]:41936 "EHLO
	mail.higgsboson.tk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162154AbcA0WDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 17:03:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/2ua/Pxdid21hc2mx.WW5Dvi
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Signed-off-by: J=C3=B6rg Thalheim <joerg@higgsboson.tk>
---
 include/net/tcp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 051dc5c2..74d8eb4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -216,7 +216,7 @@ void tcp_time_wait(struct sock *sk, int state, int time=
o);
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do exp.=
 backoff */
=20
-/* TCP initial congestion window as per draft-hkchu-tcpm-initcwnd-01 */
+/* TCP initial congestion window as per rfc6928 */
 #define TCP_INIT_CWND		10
=20
 /* Bit Flags for sysctl_tcp_fastopen */
--=20
2.7.0


--Sig_/2ua/Pxdid21hc2mx.WW5Dvi
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAEBCgBmBQJWqTx+XxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQ0QUJBMDczODJBRDU3RTZCOUFBNEU4OERD
QTQxMDZCOEQ3Q0M3OUZBAAoJEMpBBrjXzHn6WOcIAJ11gqSLjF9RCTruKwEX5g9g
QHw8IMfSJlGWQOqxx4WM0vLoSQgdsOqTjbE8p1NqnJBVsFq16o78hLGvG7u/lMfJ
vVOiWpjLyI4YsMRw18EgEjhWs5Q/zjvhLwqmM8J9GoU4vA3Qv32FmIvNjUDhrun4
dMvQ/6jIDhpguQJNH0rUCYfFfb6pA/FHHHGOZAnEE6UZz9rYeKBCtlL7nV2iP/9B
3WY/O7tcHIkkV3ejKgf52qK2plOO09RyN1cOgbTbIQ7P90vh5l8K25bSxHIq/6g2
hw5ucUZfNwGfU7TRf9r37UDBgIR8JFLgyHJwLGK54AaGbVsx8mMVfRwQmvsN+Rk=
=Rr8Q
-----END PGP SIGNATURE-----

--Sig_/2ua/Pxdid21hc2mx.WW5Dvi--
