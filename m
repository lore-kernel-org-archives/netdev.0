From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [NET] core/utils.c: digit2bin is dead static inline
Date: Sat, 12 Jan 2008 13:53:35 +0200
Message-ID: <1200138816244-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53773 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759545AbYALLxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/utils.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index 34459c4..8031eb5 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -91,17 +91,6 @@ EXPORT_SYMBOL(in_aton);
 #define IN6PTON_NULL		0x20000000	/* first/tail */
 #define IN6PTON_UNKNOWN		0x40000000
=20
-static inline int digit2bin(char c, int delim)
-{
-	if (c =3D=3D delim || c =3D=3D '\0')
-		return IN6PTON_DELIM;
-	if (c =3D=3D '.')
-		return IN6PTON_DOT;
-	if (c >=3D '0' && c <=3D '9')
-		return (IN6PTON_DIGIT | (c - '0'));
-	return IN6PTON_UNKNOWN;
-}
-
 static inline int xdigit2bin(char c, int delim)
 {
 	if (c =3D=3D delim || c =3D=3D '\0')
--=20
1.5.0.6

