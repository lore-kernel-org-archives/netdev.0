From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/21] drivers/net/tulip/eeprom.c: Remove unnecessary kmalloc casts
Date: Mon, 31 May 2010 20:23:13 -0700
Message-ID: <4fc0e008a2fc826c5696c07bf25a68440e36353b.1275360951.git.joe@perches.com>
References: <cover.1275360951.git.joe@perches.com>
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2473 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698Ab0FADXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 23:23:30 -0400
In-Reply-To: <cover.1275360951.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/eeprom.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 6002e65..3031ed9 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -120,8 +120,8 @@ static void __devinit tulip_build_fake_mediatable(struct tulip_private *tp)
 			  0x00, 0x06  /* ttm bit map */
 			};
 
-		tp->mtable = (struct mediatable *)
-			kmalloc(sizeof(struct mediatable) + sizeof(struct medialeaf), GFP_KERNEL);
+		tp->mtable = kmalloc(sizeof(struct mediatable) +
+				     sizeof(struct medialeaf), GFP_KERNEL);
 
 		if (tp->mtable == NULL)
 			return; /* Horrible, impossible failure. */
@@ -227,9 +227,9 @@ subsequent_board:
 		        return;
 		}
 
-		mtable = (struct mediatable *)
-			kmalloc(sizeof(struct mediatable) + count*sizeof(struct medialeaf),
-					GFP_KERNEL);
+		mtable = kmalloc(sizeof(struct mediatable) +
+				 count * sizeof(struct medialeaf),
+				 GFP_KERNEL);
 		if (mtable == NULL)
 			return;				/* Horrible, impossible failure. */
 		last_mediatable = tp->mtable = mtable;
-- 
1.7.0.3.311.g6a6955

