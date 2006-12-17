From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] he: tiny space savings
Date: Sun, 17 Dec 2006 15:56:22 +0300
Message-ID: <20061217125622.GA4973@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Drebes <webmaster@programmierforen.de>,
	kernel-janitors@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:10755 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbWLQM4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 07:56:22 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1661895nfa
        for <netdev@vger.kernel.org>; Sun, 17 Dec 2006 04:56:21 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Drebes <webmaster@programmierforen.de>

   text    data     bss     dec     hex filename
  20015     480      28   20523    502b drivers/atm/he.o
  19997     480      28   20505    5019 drivers/atm/he.o

Signed-off-by: Andi Drebes <webmaster@programmierforen.de>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/atm/he.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -101,7 +101,7 @@ #endif /* HE_DEBUG */
 
 /* version definition */
 
-static char *version = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
+static const char version[] = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
 
 /* declarations */
 

