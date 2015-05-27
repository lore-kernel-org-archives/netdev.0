From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] atm:he - Change 0 to false for bool type variable initialization.
Date: Wed, 27 May 2015 06:50:18 +0530
Message-ID: <1432689618-3046-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Chas Williams <3chas3@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35611 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbbE0BUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 21:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable sdh is bool type so initializing it with false value
instead of 0.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/atm/he.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 93dca2e..eb5bebc 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -116,8 +116,8 @@ static bool disable64;
 static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
-static bool irq_coalesce = 1;
-static bool sdh = 0;
+static bool irq_coalesce = true;
+static bool sdh = false;
 
 /* Read from EEPROM = 0000 0011b */
 static unsigned int readtab[] = {
-- 
1.7.9.5
