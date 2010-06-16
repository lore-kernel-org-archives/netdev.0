From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 7/9] cxgb4: add a missing error interrupt
Date: Wed, 16 Jun 2010 15:01:14 -0700
Message-ID: <1276725676-31514-8-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
 <1276725676-31514-3-git-send-email-dm@chelsio.com>
 <1276725676-31514-4-git-send-email-dm@chelsio.com>
 <1276725676-31514-5-git-send-email-dm@chelsio.com>
 <1276725676-31514-6-git-send-email-dm@chelsio.com>
 <1276725676-31514-7-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28902 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759364Ab0FPWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:18 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1JgW032133
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:19 -0700
In-Reply-To: <1276725676-31514-7-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 4c956fb..5c058ea 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -1135,6 +1135,7 @@ static void cim_intr_handler(struct adapter *adapter)
 static void ulprx_intr_handler(struct adapter *adapter)
 {
 	static struct intr_info ulprx_intr_info[] = {
+		{ 0x1800000, "ULPRX context error", -1, 1 },
 		{ 0x7fffff, "ULPRX parity error", -1, 1 },
 		{ 0 }
 	};
-- 
1.5.4

