From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 2/2] Fix return type of test_free() prorotype
Date: Fri, 09 Oct 2015 04:03:50 +0100
Message-ID: <1444359830.2956.296.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gg9hzJRWVblIbajULpwL"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36476 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932587AbbJIDED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 23:04:03 -0400
Received: from deadeye.wl.decadent.org.uk ([192.168.4.247] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNyT-0003IM-1d
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 04:04:01 +0100
Received: from ben by deadeye with local (Exim 4.86)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNyN-0001YL-Sz
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 04:03:55 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gg9hzJRWVblIbajULpwL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The return type should be void, consistent with the definition and
with the standard free() function.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I've applied this post-4.2.

Ben.

 internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/internal.h b/internal.h
index 156770c..b5ef646 100644
--- a/internal.h
+++ b/internal.h
@@ -148,7 +148,7 @@ void *test_calloc(size_t nmemb, size_t size);
 char *test_strdup(const char *s);
 #undef strdup
 #define strdup(s) test_strdup(s)
-void *test_free(void *ptr);
+void test_free(void *ptr);
 #undef free
 #define free(ptr) test_free(ptr)
 void *test_realloc(void *ptr, size_t size);
--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.
--=-gg9hzJRWVblIbajULpwL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhculue/yOyVhhEJAQrwihAAwr7y0ODof7ZvvPsG+ZH+YL8HcymiIT0x
54P/phI0zLE8DcUumgpq86Jg/MuYe7mYCzjSvAtyC8VVzGWbzn37YXvHBUyQDncC
Ew2k21ft2xuYbfKgkTWkqGy/0rdatXi0AtThbZ6g5SScPCH9AIcanAj4NdkiiaeT
J4yPH/LLZAzPST+F45dPtxOnjxvJz7nwt91aTPfK5A7BJps117KOP0rK8V85is5N
faJNT26brTDpfRM/oFG3dnzMoLJrovq5/jb+543cZEqoMRsLSlrVaTKfbxQoFgwZ
k8odZfO6IxN7yQjocRCmYAQ46AN4SRYyf36R2Fv0dmmhqVD1LQBRBOf+CHD9ihHq
XRuTX1kF2+KCoqnXz/agoRxZTx7kuYyPMvQL3p3PfIv60bAj7sBigl05QG7zDvCH
OL8QYHGkvZQTxbfmmtrzIRg3aYNbwSV3Jhih3AsF7w/AHCi5vLIl0TZQfJM+lIvw
xO4avJPxsGqlIbuFKL4UxbIyLmMOCxzXCfsRHMvhkbyiNK1XOKcvWMTgyhjNjKMY
bR92z5QhlwfkzpipJEjpPyBRsUBBRm95ZFduxdGHhzRet9DEfIiht8XJDdbCbmTz
gXkFN7yP/ORIMjIU9n7C8gQBP747Tw+HO7ssytRQME0y2X3OjGIo3FmkB6q2RUmQ
uivFVoNF6pY=
=qUBO
-----END PGP SIGNATURE-----

--=-gg9hzJRWVblIbajULpwL--
