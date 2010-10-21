From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/12] e1000: make e1000_reinit_safe local
Date: Thu, 21 Oct 2010 10:50:57 -0700
Message-ID: <20101021175149.150694790@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36324 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756533Ab0JUSBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:12 -0400
Content-Disposition: inline; filename=e1000-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/e1000/e1000_main.c	2010-10-21 09:35:54.643519367 -0700
+++ b/drivers/net/e1000/e1000_main.c	2010-10-21 09:36:01.380214771 -0700
@@ -521,7 +521,7 @@ void e1000_down(struct e1000_adapter *ad
 	e1000_clean_all_rx_rings(adapter);
 }
 
-void e1000_reinit_safe(struct e1000_adapter *adapter)
+static void e1000_reinit_safe(struct e1000_adapter *adapter)
 {
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);


