From: David Miller <davem@davemloft.net>
Subject: Is typing "make" too much to ask?
Date: Fri, 28 Mar 2008 19:53:25 -0700 (PDT)
Message-ID: <20080328.195325.220482995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754725AbYC2Cx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 22:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I merely ask that things submitted to me actully compile... :-(

commit 9f09243890a4e7d2e06d40b56f26a64f88c6ec8b
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 28 19:51:40 2008 -0700

    [LLC]: Kill llc_station_mac_sa symbol export.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 00de27c..50d5b10 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -179,7 +179,6 @@ static void __exit llc_exit(void)
 module_init(llc_init);
 module_exit(llc_exit);
 
-EXPORT_SYMBOL(llc_station_mac_sa);
 EXPORT_SYMBOL(llc_sap_list);
 EXPORT_SYMBOL(llc_sap_list_lock);
 EXPORT_SYMBOL(llc_sap_find);
