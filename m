From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] netiucv: remove unused macro
Date: Mon, 24 Jun 2013 13:21:48 +0200
Message-ID: <20130624112226.438466270@de.ibm.com>
References: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:39541 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab3FXLWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:32 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:18:25 +0100
Content-Disposition: inline; filename=600-netiucv-hex-dump.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

If someone is interested to dump something they may consider to use
print_hex_dump() or print_hex_dump_bytes() kernel helpers.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/netiucv.c |   20 --------------------
 1 file changed, 20 deletions(-)

--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -130,26 +130,6 @@ static inline int iucv_dbf_passes(debug_
 /**
  * some more debug stuff
  */
-#define IUCV_HEXDUMP16(importance,header,ptr) \
-PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
-		   "%02x %02x %02x %02x  %02x %02x %02x %02x\n", \
-		   *(((char*)ptr)),*(((char*)ptr)+1),*(((char*)ptr)+2), \
-		   *(((char*)ptr)+3),*(((char*)ptr)+4),*(((char*)ptr)+5), \
-		   *(((char*)ptr)+6),*(((char*)ptr)+7),*(((char*)ptr)+8), \
-		   *(((char*)ptr)+9),*(((char*)ptr)+10),*(((char*)ptr)+11), \
-		   *(((char*)ptr)+12),*(((char*)ptr)+13), \
-		   *(((char*)ptr)+14),*(((char*)ptr)+15)); \
-PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
-		   "%02x %02x %02x %02x  %02x %02x %02x %02x\n", \
-		   *(((char*)ptr)+16),*(((char*)ptr)+17), \
-		   *(((char*)ptr)+18),*(((char*)ptr)+19), \
-		   *(((char*)ptr)+20),*(((char*)ptr)+21), \
-		   *(((char*)ptr)+22),*(((char*)ptr)+23), \
-		   *(((char*)ptr)+24),*(((char*)ptr)+25), \
-		   *(((char*)ptr)+26),*(((char*)ptr)+27), \
-		   *(((char*)ptr)+28),*(((char*)ptr)+29), \
-		   *(((char*)ptr)+30),*(((char*)ptr)+31));
-
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 /* dummy device to make sure netiucv_pm functions are called */
