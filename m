From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 15/25] wimax/i2400m: increase tx queue length from 5 to 20 [v1]
Date: Fri, 14 May 2010 14:45:14 -0700
Message-ID: <ded0fd62a8a7cb3b12bb007079bff2b858a12d2b.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:32478 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932537Ab0ENVtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:15 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch increases the tx_queue_len to 20 so as to
minimize the jitter in the throughput.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index fc3754a..7d7b5ef 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -88,7 +88,11 @@ enum {
 	 * might take to get out of IDLE / negotiate it with the base
 	 * station. We add 1sec for good measure. */
 	I2400M_TX_TIMEOUT = 21 * HZ,
-	I2400M_TX_QLEN = 5,
+	/*
+	 * Experimentation has determined that, 20 to be a good value
+	 * for minimizing the jitter in the throughput.
+	 */
+	I2400M_TX_QLEN = 20,
 };
 
 
-- 
1.6.6.1

