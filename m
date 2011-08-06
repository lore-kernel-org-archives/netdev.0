From: Dan Carpenter <error27@gmail.com>
Subject: [patch] qla3xxx: remove an extra semi-colon
Date: Sat, 6 Aug 2011 07:26:41 -0700
Message-ID: <20110806142641.GB10373@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "supporter:QLOGIC QLA3XXX NE..." <linux-driver@qlogic.com>,
	"open list:QLOGIC QLA3XXX NE..." <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33504 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab1HFO0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 10:26:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The define is only used one place, and it's at the end of a line so
the semi-colon doesn't affect anything.  But let's clean it up
anyway.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 2f69140..ccde806 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1650,7 +1650,7 @@ static int ql_mii_setup(struct ql3_adapter *qdev)
 				 SUPPORTED_1000baseT_Half |	\
 				 SUPPORTED_1000baseT_Full |	\
 				 SUPPORTED_Autoneg |		\
-				 SUPPORTED_TP);			\
+				 SUPPORTED_TP)			\
 
 static u32 ql_supported_modes(struct ql3_adapter *qdev)
 {
