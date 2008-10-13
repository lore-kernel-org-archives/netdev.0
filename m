From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH 2/2] enic: Fix Kconfig headline description
Date: Mon, 13 Oct 2008 13:36:30 -0700
Message-ID: <adaej2kp701.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scofeldm@cisco.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:11248 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbYJMUgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 16:36:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

I don't think the enic driver has anything to do with Mark Everett
(http://en.wikipedia.org/wiki/A_Man_Called_E).  Fix the Kconfig
description.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
And this is the other half of
https://kerneltrap.org/mailarchive/linux-netdev/2008/9/20/3350614/thread
that seems to have gotten dropped.  Please apply.

 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e9d5294..1d8af33 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2400,7 +2400,7 @@ config EHEA
 	  will be called ehea.
 
 config ENIC
-	tristate "E, the Cisco 10G Ethernet NIC"
+	tristate "Cisco 10G Ethernet NIC support"
 	depends on PCI && INET
 	select INET_LRO
 	help
