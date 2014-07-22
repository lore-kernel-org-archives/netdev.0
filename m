From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] atm: Remove fix me in solos-pci
Date: Tue, 22 Jul 2014 00:07:20 -0400
Message-ID: <1406002040-7334-1-git-send-email-xerofoify@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:56810 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbaGVEH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 00:07:26 -0400
Received: by mail-ie0-f170.google.com with SMTP id rl12so7712096iec.29
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 21:07:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes a fix me as the default statement for solos_bh is correct
and needs no fixing.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/atm/solos-pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 943cf0d..58a0a8f 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -851,7 +851,7 @@ static void solos_bh(unsigned long card_arg)
 				break;
 
 			case PKT_COMMAND:
-			default: /* FIXME: Not really, surely? */
+			default:
 				if (process_command(card, port, skb))
 					break;
 				spin_lock(&card->cli_queue_lock);
-- 
1.9.1
