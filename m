From: frank.blaschka@de.ibm.com
Subject: [patch 4/6] [PATCH] qeth: Update Kconfig wording
Date: Mon, 21 Jan 2013 13:30:21 +0100
Message-ID: <20130121123037.534460661@de.ibm.com>
References: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:36852 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599Ab3AUMam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:42 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:29:28 -0000
Content-Disposition: inline; filename=603-qeth-kconfig-help.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Refer to virtual NICs instead of GuestLANs.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/Kconfig
+++ b/drivers/s390/net/Kconfig
@@ -74,8 +74,8 @@ config QETH
 	depends on CCW && NETDEVICES && IP_MULTICAST && QDIO
 	help
 	  This driver supports the IBM System z OSA Express adapters
-	  in QDIO mode (all media types), HiperSockets interfaces and VM GuestLAN
-	  interfaces in QDIO and HIPER mode.
+	  in QDIO mode (all media types), HiperSockets interfaces and z/VM
+	  virtual NICs for Guest LAN and VSWITCH.
 	
 	  For details please refer to the documentation provided by IBM at
 	  <http://www.ibm.com/developerworks/linux/linux390>
