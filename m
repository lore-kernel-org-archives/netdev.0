From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 07/12] test-features.c: add braces around array initialization
Date: Thu,  3 Mar 2016 20:23:20 -0800
Message-ID: <1457065405-19049-8-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34115 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510AbcCDEXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:46 -0500
Received: by mail-pa0-f68.google.com with SMTP id hj7so2395809pac.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:46 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This fixes:
  test-features.c:21:1: error: missing braces around initializer [-Werr=
or=3Dmissing-braces]
   cmd_gssetinfo =3D { { ETHTOOL_GSSET_INFO, 0, 1ULL << ETH_SS_FEATURES=
 }, 34 };
   ^


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
