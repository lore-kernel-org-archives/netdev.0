From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4: increase serial number length
Date: Tue, 27 Apr 2010 15:24:16 -0700
Message-ID: <1272407056-11699-2-git-send-email-dm@chelsio.com>
References: <1272407056-11699-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23685 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353Ab0D0W3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:29:50 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o3RMToWI003264
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:29:50 -0700
In-Reply-To: <1272407056-11699-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards have longer serial numbers in their VPD, up to 24 bytes.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 4b35dc7..8856a75 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -53,7 +53,7 @@
 
 enum {
 	MAX_NPORTS = 4,     /* max # of ports */
-	SERNUM_LEN = 16,    /* Serial # length */
+	SERNUM_LEN = 24,    /* Serial # length */
 	EC_LEN     = 16,    /* E/C length */
 	ID_LEN     = 16,    /* ID length */
 };
-- 
1.5.4

