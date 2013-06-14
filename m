From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] net: vlan: fix comment for vlan_ethhdr->h_vlan_proto
Date: Fri, 14 Jun 2013 17:07:01 +0200
Message-ID: <1371222421-6397-1-git-send-email-olaf@aepfle.de>
Cc: Olaf Hering <olaf@aepfle.de>
To: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p04-ob.rzone.de ([81.169.146.176]:41370 "EHLO
	mo-p04-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab3FNPWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 11:22:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After addition of 8021AD h_vlan_proto can be either ETH_P_8021Q or
ETH_P_8021AD.

Signed-off-by: Olaf Hering <olaf@aepfle.de>
---
 include/linux/if_vlan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 52bd03b..637fa71d 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -44,7 +44,7 @@ struct vlan_hdr {
  *	struct vlan_ethhdr - vlan ethernet header (ethhdr + vlan_hdr)
  *	@h_dest: destination ethernet address
  *	@h_source: source ethernet address
- *	@h_vlan_proto: ethernet protocol (always 0x8100)
+ *	@h_vlan_proto: ethernet protocol
  *	@h_vlan_TCI: priority and VLAN ID
  *	@h_vlan_encapsulated_proto: packet type ID or len
  */
