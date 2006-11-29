From: Horms <horms@verge.net.au>
Subject: [IPVS] make ip_vs_sync.c <= 80col wide
Date: Wed, 29 Nov 2006 10:01:37 +0900
Message-ID: <20061129010135.GB25535@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Wensong Zhan <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:19356 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1758705AbWK2BpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 20:45:02 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make ip_vs_sync.c <= 80col wide

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2006-11-29 09:53:51.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_sync.c	2006-11-29 09:54:52.000000000 +0900
@@ -847,10 +847,12 @@
 
 	ip_vs_sync_state |= state;
 	if (state == IP_VS_STATE_MASTER) {
-		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn, sizeof(ip_vs_master_mcast_ifn));
+		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
+			sizeof(ip_vs_master_mcast_ifn));
 		ip_vs_master_syncid = syncid;
 	} else {
-		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn, sizeof(ip_vs_backup_mcast_ifn));
+		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
+			sizeof(ip_vs_backup_mcast_ifn));
 		ip_vs_backup_syncid = syncid;
 	}
 
@@ -876,7 +878,8 @@
 
 	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, current->pid);
 	IP_VS_INFO("stopping sync thread %d ...\n",
-		   (state == IP_VS_STATE_MASTER) ? sync_master_pid : sync_backup_pid);
+		   (state == IP_VS_STATE_MASTER) ?
+		   sync_master_pid : sync_backup_pid);
 
 	__set_current_state(TASK_UNINTERRUPTIBLE);
 	add_wait_queue(&stop_sync_wait, &wait);
