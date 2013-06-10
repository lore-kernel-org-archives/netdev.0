From: <Narendra_K@Dell.com>
Subject: [PATCH net-next] doc:networking: Update comment for dev_id field in
 netdevice.h
Date: Mon, 10 Jun 2013 19:34:03 +0530
Message-ID: <20130610140325.GA1383@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:59210 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab3FJOEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 10:04:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the comment for 'dev_id' field in
'include/linux/netdevice.h' to reflect the intended
usage of 'dev_id'.

References: http://marc.info/?l=linux-netdev&m=136992115300526&w=2
References: http://marc.info/?l=linux-netdev&m=137062569014612&w=2

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 include/linux/netdevice.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8f967e3..a43712e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1142,8 +1142,10 @@ struct net_device {
 	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned char		neigh_priv_len;
-	unsigned short          dev_id;		/* for shared network cards */
-
+	unsigned short          dev_id;		/* Used to differentiate devices
+						 * that share the same link
+						 * layer address
+						 */
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
-- 
1.8.0.1

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
