From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 6/9] bnx2x: annotate pointers in struct bnx2x_fastpath
Date: Tue, 20 Jan 2009 21:50:50 -0800
Message-ID: <1232517050.9701.24.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:49189 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbZAUFu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:58 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3470392rvb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 7bda49d..5ac71ac 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -234,7 +234,7 @@ struct bnx2x_fastpath {
 	u16			tx_pkt_cons;
 	u16			tx_bd_prod;
 	u16			tx_bd_cons;
-	u16			*tx_cons_sb;
+	__le16			*tx_cons_sb;
 
 	u16			fp_c_idx;
 	u16			fp_u_idx;
@@ -246,8 +246,8 @@ struct bnx2x_fastpath {
 	u16			rx_sge_prod;
 	/* The last maximal completed SGE */
 	u16			last_max_sge;
-	u16			*rx_cons_sb;
-	u16			*rx_bd_cons_sb;
+	__le16			*rx_cons_sb;
+	__le16			*rx_bd_cons_sb;
 
 	unsigned long		tx_pkt,
 				rx_pkt,
-- 
1.6.1.249.g455e5


