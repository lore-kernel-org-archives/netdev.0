From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 4/6] qeth: s390 ethernet device driver dependency
Date: Wed, 22 Oct 2014 12:18:05 +0200
Message-ID: <1413973087-18740-5-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:38262 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbaJVKSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 06:18:16 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:18:15 +0100
In-Reply-To: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Compile the s390 10GB ethernet device driver only when
ETHERNET has been defined in the kernel configuration file.
Right now the qeth device driver is always built regardless
of which network connectivity is active.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/Kconfig b/drivers/s390/net/Kconfig
index 8b3f559..f1b5111 100644
--- a/drivers/s390/net/Kconfig
+++ b/drivers/s390/net/Kconfig
@@ -71,7 +71,7 @@ config CLAW
 config QETH
 	def_tristate y
 	prompt "Gigabit Ethernet device support"
-	depends on CCW && NETDEVICES && IP_MULTICAST && QDIO
+	depends on CCW && NETDEVICES && IP_MULTICAST && QDIO && ETHERNET
 	help
 	  This driver supports the IBM System z OSA Express adapters
 	  in QDIO mode (all media types), HiperSockets interfaces and z/VM
-- 
1.8.5.5
