From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] tc: add canid ematch to ematch_map
Date: Thu, 22 Nov 2012 20:53:44 +0100
Message-ID: <1353614024-18248-1-git-send-email-mkl@pengutronix.de>
Cc: Rostislav Lisovy <lisovy@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41752 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965097Ab2KVTxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:53:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rostislav Lisovy <lisovy@gmail.com>

The canid ematch has been added in commit:

7b5f30e Ematch used to classify CAN frames according to their identifiers

But the corresponding entry in etc/iproute2/ematch_map was lost. This patch
adds the missing entry in ematch_map, otherweise tc would complain:

Error: Unable to find ematch "canid" in /etc/iproute2/ematch_map
Please assign a unique ID to the ematch kind the suggested entry is:
        7       canid

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 etc/iproute2/ematch_map |    1 +
 1 file changed, 1 insertion(+)

diff --git a/etc/iproute2/ematch_map b/etc/iproute2/ematch_map
index 69b007d..1823983 100644
--- a/etc/iproute2/ematch_map
+++ b/etc/iproute2/ematch_map
@@ -3,4 +3,5 @@
 2	nbyte
 3	u32
 4	meta
+7	canid
 8	ipset
-- 
1.7.10.4
