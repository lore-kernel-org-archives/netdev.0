From: Neil Horman <nhorman@tuxdriver.com>
Subject: [Patch 1/5] Network Drop Monitor: Add netlink protocol identifer
Date: Tue, 3 Mar 2009 12:00:14 -0500
Message-ID: <20090303170014.GB1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52390 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbZCCRAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 12:00:23 -0500
Received: from nat-pool-rdu.redhat.com ([66.187.233.202] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1LeXye-0005Dc-Jn
	for netdev@vger.kernel.org; Tue, 03 Mar 2009 12:00:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Network Drop Monitor: Add Netlink protocol identifier
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 netlink.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 1e6bf99..d4ac636 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -24,6 +24,7 @@
 /* leave room for NETLINK_DM (DM Events) */
 #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
 #define NETLINK_ECRYPTFS	19
+#define NETLINK_DRPMON		20	/* Netork packet drop alerts */
 
 #define MAX_LINKS 32		
 
