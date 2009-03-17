From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 19/30] solos: Remove superfluous wait_queue_head_t from
 struct solos_param
Date: Tue, 17 Mar 2009 21:29:30 +0000
Message-ID: <1237325370.27681.348.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37667 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757803AbZCQV3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:38 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqu-0001vr-Bb
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:36 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index f2736dd..8121f85 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -123,7 +123,6 @@ struct solos_param {
 	pid_t pid;
 	int port;
 	struct sk_buff *response;
-	wait_queue_head_t wq;
 };
 
 #define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
-- 
1.6.0.6


