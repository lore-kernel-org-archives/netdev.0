From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 10/12] headers, can: Add missing #include to
 <linux/can/bcm.h>
Date: Mon, 08 Aug 2011 14:20:55 +0100
Message-ID: <1312809655.2591.1149.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50093 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751357Ab1HHNU6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:20:58 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/can/bcm.h> uses type canid_t, defined in <linux/can.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/can/bcm.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
index 1432b27..e96154d 100644
--- a/include/linux/can/bcm.h
+++ b/include/linux/can/bcm.h
@@ -15,6 +15,7 @@
 #define CAN_BCM_H
 
 #include <linux/types.h>
+#include <linux/can.h>
 
 /**
  * struct bcm_msg_head - head of messages to/from the broadcast manager
-- 
1.7.5.4



