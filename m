From: akpm@linux-foundation.org
Subject: [patch 10/11] hysdn: remove the packed attribute from PofTimStamp_tag
Date: Wed, 30 Jul 2008 12:37:42 -0700
Message-ID: <200807301937.m6UJbhxo012458@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dhowells@redhat.com, kkeil@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754027AbYG3TxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:53:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Remove the packed attribute from PofTimStamp_tag in the hysdn driver as the
thing being packed is just an array of chars and so is unpackable.

This deals with a compiler warning:

In file included from drivers/isdn/hysdn/hysdn_boot.c:19:
drivers/isdn/hysdn/hysdn_pof.h:63: warning: 'packed' attribute ignored for field of type 'unsigned char[40]'

Signed-off-by: David Howells <dhowells@redhat.com>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hysdn/hysdn_pof.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hysdn/hysdn_pof.h~hysdn-remove-the-packed-attribute-from-poftimstamp_tag drivers/isdn/hysdn/hysdn_pof.h
--- a/drivers/isdn/hysdn/hysdn_pof.h~hysdn-remove-the-packed-attribute-from-poftimstamp_tag
+++ a/drivers/isdn/hysdn/hysdn_pof.h
@@ -60,7 +60,7 @@ typedef struct PofRecHdr_tag {	/* Pof re
 
 typedef struct PofTimeStamp_tag {
 /*00 */ unsigned long UnixTime __attribute__((packed));
-	/*04 */ unsigned char DateTimeText[0x28] __attribute__((packed));
+	/*04 */ unsigned char DateTimeText[0x28];
 	/* =40 */
 /*2C */
 } tPofTimeStamp;
_
