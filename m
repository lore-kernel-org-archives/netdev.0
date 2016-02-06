From: Michael McConville <mmcco@mykolab.com>
Subject: [PATCH] dscc4: Undefined signed int shift
Date: Fri, 5 Feb 2016 20:46:25 -0500
Message-ID: <20160206014624.GA20990@thinkpad.swarthmore.edu>
Content-Type: text/plain; charset=utf-8
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.mykolab.com ([95.128.36.1]:6781 "EHLO mx-out02.mykolab.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750748AbcBFBqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 20:46:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My analysis in the below mail applies, although the second part is
unnecessary because i isn't used in arithmetic operations here:

https://marc.info/?l=openbsd-tech&m=145377854103866&w=2

Thanks for your time.

Signed-off-by: Michael McConville <mmcco@mykolab.com>
---
 drivers/net/wan/dscc4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 7a72407..6292259 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1626,7 +1626,7 @@ try:
 		if (state & Xpr) {
 			void __iomem *scc_addr;
 			unsigned long ring;
-			int i;
+			unsigned int i;
 
 			/*
 			 * - the busy condition happens (sometimes);
