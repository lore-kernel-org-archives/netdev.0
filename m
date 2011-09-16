From: Andi Kleen <andi@firstfloor.org>
Subject: IRDA: Fix global type conflicts in net/irda/irsysctl.c
Date: Fri, 16 Sep 2011 10:32:51 -0700
Message-ID: <20110916173251.GA25560@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: samuel@sortiz.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15761 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754331Ab1IPRcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 13:32:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The externs here didn't agree with the declarations in qos.c.

Better would be probably to move this into a header, but since it's
common practice to have naked externs with sysctls I left it for now.

Cc: samuel@sortiz.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>

diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index d0b70da..be22ad2 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -40,9 +40,9 @@ extern int  sysctl_slot_timeout;
 extern int  sysctl_fast_poll_increase;
 extern char sysctl_devname[];
 extern int  sysctl_max_baud_rate;
-extern int  sysctl_min_tx_turn_time;
-extern int  sysctl_max_tx_data_size;
-extern int  sysctl_max_tx_window;
+extern unsigned  sysctl_min_tx_turn_time;
+extern unsigned  sysctl_max_tx_data_size;
+extern unsigned  sysctl_max_tx_window;
 extern int  sysctl_max_noreply_time;
 extern int  sysctl_warn_noreply_time;
 extern int  sysctl_lap_keepalive_time;
-- 
ak@linux.intel.com -- Speaking for myself only
