From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/1] s390: fix /proc/interrupts output
Date: Wed, 25 Mar 2015 16:31:37 +0100
Message-ID: <1427297497-22104-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1427297497-22104-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:50499 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbbCYPbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:31:46 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 25 Mar 2015 15:31:44 -0000
In-Reply-To: <1427297497-22104-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

The irqclass_sub_desc array and enum interruption_class are out of sync
thus /proc/interrupts is broken. Remove IRQIO_CLW.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 arch/s390/include/asm/irq.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/s390/include/asm/irq.h b/arch/s390/include/asm/irq.h
index 343ea7c..ff95d15 100644
--- a/arch/s390/include/asm/irq.h
+++ b/arch/s390/include/asm/irq.h
@@ -57,7 +57,6 @@ enum interruption_class {
 	IRQIO_TAP,
 	IRQIO_VMR,
 	IRQIO_LCS,
-	IRQIO_CLW,
 	IRQIO_CTC,
 	IRQIO_APB,
 	IRQIO_ADM,
-- 
2.1.4
