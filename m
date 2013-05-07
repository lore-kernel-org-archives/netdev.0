From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 2/9] net: sh-eth: Add comment to bit of EDSR about SH7757
Date: Tue,  7 May 2013 14:17:48 +0900
Message-ID: <1367903875-32606-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:63679 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab3EGFSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:13 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so137675pdi.29
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:13 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH7757 uses EDSR register. This adds about SH7757.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 7ccf58c..71c5559 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -166,7 +166,7 @@ enum {
 /*
  * Register's bits
  */
-/* EDSR : sh7734, sh7763 and r8a7740 only */
+/* EDSR : sh7734, sh7763, sh7757 and r8a7740 only */
 enum EDSR_BIT {
 	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
 };
-- 
1.7.10.4
