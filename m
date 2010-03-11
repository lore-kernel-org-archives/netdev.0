From: akpm@linux-foundation.org
Subject: [patch 1/3] isdn: misplaced parenthesis in pof_handle_data()
Date: Thu, 11 Mar 2010 14:07:22 -0800
Message-ID: <201003112207.o2BM7M3U013456@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46396 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758265Ab0CKWH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:07:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The parenthesis was misplaced.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hysdn/hysdn_boot.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hysdn/hysdn_boot.c~isdn-misplaced-parenthesis-in-pof_handle_data drivers/isdn/hysdn/hysdn_boot.c
--- a/drivers/isdn/hysdn/hysdn_boot.c~isdn-misplaced-parenthesis-in-pof_handle_data
+++ a/drivers/isdn/hysdn/hysdn_boot.c
@@ -143,7 +143,7 @@ pof_handle_data(hysdn_card * card, int d
 					     (boot->pof_recid == TAG_CABSDATA) ? "CABSDATA" : "ABSDATA",
 					     datlen, boot->pof_recoffset);
 
-			if ((boot->last_error = card->writebootseq(card, boot->buf.BootBuf, datlen) < 0))
+			if ((boot->last_error = card->writebootseq(card, boot->buf.BootBuf, datlen)) < 0)
 				return (boot->last_error);	/* error writing data */
 
 			if (boot->pof_recoffset + datlen >= boot->pof_reclen)
_
