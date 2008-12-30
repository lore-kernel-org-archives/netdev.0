From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] isdn: capi: &&/|| typos
Date: Tue, 30 Dec 2008 13:31:38 +0100
Message-ID: <495A14AA.2060200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:59217 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbYL3Mbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 07:31:40 -0500
Received: by ewy10 with SMTP id 10so5483258ewy.13
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2008 04:31:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct two typos.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index d5b4cc3..6501202 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -1519,7 +1519,7 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
 		int digit2 = 0;
 		if (!isdigit(*s)) return -3;
 		while (isdigit(*s)) { digit1 = digit1*10 + (*s - '0'); s++; }
-		if (digit1 <= 0 && digit1 > 30) return -4;
+		if (digit1 <= 0 || digit1 > 30) return -4;
 		if (*s == 0 || *s == ',' || *s == ' ') {
 			bmask |= (1 << digit1);
 			digit1 = 0;
@@ -1530,7 +1530,7 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
 		s++;
 		if (!isdigit(*s)) return -3;
 		while (isdigit(*s)) { digit2 = digit2*10 + (*s - '0'); s++; }
-		if (digit2 <= 0 && digit2 > 30) return -4;
+		if (digit2 <= 0 || digit2 > 30) return -4;
 		if (*s == 0 || *s == ',' || *s == ' ') {
 			if (digit1 > digit2)
 				for (i = digit2; i <= digit1 ; i++)
