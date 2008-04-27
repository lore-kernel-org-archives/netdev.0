From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: eepro autoport typo
Date: Sat, 26 Apr 2008 23:44:03 -0700
Message-ID: <1209278643.14173.48.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:10551 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbYD0Gn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 02:43:58 -0400
Received: by wa-out-1112.google.com with SMTP id m16so7079657waf.23
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 23:43:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found by sparse dubious !x & y warning...hidden in the GetBit macro
why !Word doesn't make any sense.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/eepro.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 83bda6c..56f5049 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -633,7 +633,7 @@ static void __init printEEPROMInfo(struct net_device *dev)
 		printk(KERN_DEBUG " PC: %d\n", GetBit(Word,ee_PC));
 		printk(KERN_DEBUG " TPE/AUI: %d\n", GetBit(Word,ee_TPE_AUI));
 		printk(KERN_DEBUG " Jabber: %d\n", GetBit(Word,ee_Jabber));
-		printk(KERN_DEBUG " AutoPort: %d\n", GetBit(!Word,ee_Jabber));
+		printk(KERN_DEBUG " AutoPort: %d\n", !GetBit(Word,ee_AutoPort));
 		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));
 	}
 
-- 
1.5.5.1.270.g89765



