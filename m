From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v3 07/12] test-features.c: add braces around array initialization
Date: Fri,  4 Mar 2016 16:42:08 -0800
Message-ID: <1457138533-2417-8-git-send-email-ddecotig@gmail.com>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33805 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759441AbcCEAmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:42:33 -0500
Received: by mail-pf0-f193.google.com with SMTP id 184so3975206pff.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:42:33 -0800 (PST)
In-Reply-To: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This fixes:
  test-features.c:21:1: error: missing braces around initializer [-Werr=
or=3Dmissing-braces]
   cmd_gssetinfo =3D { { ETHTOOL_GSSET_INFO, 0, 1ULL << ETH_SS_FEATURES=
 }, 34 };
   ^


Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: David Decotigny <decot@googlers.com>
---
 test-features.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test-features.c b/test-features.c
index d7bd994..6ebb364 100644
--- a/test-features.c
+++ b/test-features.c
@@ -18,7 +18,7 @@ static const struct {
 	struct ethtool_sset_info cmd;
 	u32 data[1];
 }
-cmd_gssetinfo =3D { { ETHTOOL_GSSET_INFO, 0, 1ULL << ETH_SS_FEATURES }=
, 34 };
+cmd_gssetinfo =3D { { ETHTOOL_GSSET_INFO, 0, 1ULL << ETH_SS_FEATURES }=
, { 34 } };
=20
 static const struct ethtool_value
 cmd_grxcsum_off =3D { ETHTOOL_GRXCSUM, 0 },
--=20
2.7.0.rc3.207.g0ac5344
