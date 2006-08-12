From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: ZD1211B ASIC/FWT, not jointly decoder
Date: Sat, 12 Aug 2006 17:59:12 +0100 (BST)
Message-ID: <20060812165912.ABD018E776C@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:52574 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932560AbWHLQ7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:59:09 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vendor driver chooses this value based on an ifndef ASIC,
and ASIC is never defined.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---

This should go into 2.6.18 as it fixed TX on one of my devices.

 zd_chip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -717,7 +717,7 @@ static int zd1211b_hw_reset_phy(struct z
 		{ CR21,  0x0e }, { CR22,  0x23 }, { CR23,  0x90 },
 		{ CR24,  0x14 }, { CR25,  0x40 }, { CR26,  0x10 },
 		{ CR27,  0x10 }, { CR28,  0x7f }, { CR29,  0x80 },
-		{ CR30,  0x49 }, /* jointly decoder, no ASIC */
+		{ CR30,  0x4b }, /* ASIC/FWT, no jointly decoder */
 		{ CR31,  0x60 }, { CR32,  0x43 }, { CR33,  0x08 },
 		{ CR34,  0x06 }, { CR35,  0x0a }, { CR36,  0x00 },
 		{ CR37,  0x00 }, { CR38,  0x38 }, { CR39,  0x0c },
