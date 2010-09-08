From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] atlx: make strings const
Date: Wed, 8 Sep 2010 15:18:36 -0700
Message-ID: <20100908151836.3c40cc81@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43631 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756259Ab0IHWSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 18:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Chris Snook <chris.snook@gmail.com>

--- a/drivers/net/atlx/atl2.c	2010-09-02 10:51:39.529679405 -0700
+++ b/drivers/net/atlx/atl2.c	2010-09-02 10:52:23.904667707 -0700
@@ -51,10 +51,10 @@
 
 #define ATL2_DRV_VERSION "2.2.3"
 
-static char atl2_driver_name[] = "atl2";
+static const char atl2_driver_name[] = "atl2";
 static const char atl2_driver_string[] = "Atheros(R) L2 Ethernet Driver";
-static char atl2_copyright[] = "Copyright (c) 2007 Atheros Corporation.";
-static char atl2_driver_version[] = ATL2_DRV_VERSION;
+static const char atl2_copyright[] = "Copyright (c) 2007 Atheros Corporation.";
+static const char atl2_driver_version[] = ATL2_DRV_VERSION;
 
 MODULE_AUTHOR("Atheros Corporation <xiong.huang@atheros.com>, Chris Snook <csnook@redhat.com>");
 MODULE_DESCRIPTION("Atheros Fast Ethernet Network Driver");
