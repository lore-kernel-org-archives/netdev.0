From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] ATM: misplaced parentheses?
Date: Tue, 17 Feb 2009 10:59:36 +0100
Message-ID: <499A8A88.2070300@gmail.com>
References: <49983DB0.6040008@gmail.com> <200902162202.n1GM2aI0009056@cmf.nrl.navy.mil> <20090216223001.GW28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas3@users.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:48884 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbZBQJ7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 04:59:39 -0500
Received: by bwz5 with SMTP id 5so3821065bwz.13
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 01:59:37 -0800 (PST)
In-Reply-To: <20090216223001.GW28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:

> while you technically only need parens around ?:, in this case it's
> better to keep it fully parenthesised - more readable that way.
> 
> The lack of parens around ?: in the current tree is an obvious bug.

Ok, with extra for clarity:

-------------------------->8------------------8<---------------------------
Add missing parentheses

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 144a49f..8733a2e 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -901,7 +901,7 @@ static int __devinit eeprom_read(struct lanai_dev *lanai)
 		clock_l(); udelay(5);
 		for (i = 128; i != 0; i >>= 1) {   /* write command out */
 			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
-			    (data & i) ? CONFIG1_PROMDATA : 0;
+			    ((data & i) ? CONFIG1_PROMDATA : 0);
 			if (lanai->conf1 != tmp) {
 				set_config1(tmp);
 				udelay(5);	/* Let new data settle */
