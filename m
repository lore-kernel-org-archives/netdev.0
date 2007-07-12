From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Fix memset length
Date: Thu, 12 Jul 2007 20:16:39 +0200
Message-ID: <46967007.1050200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020407050103090804060608"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54262 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760857AbXGLSQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020407050103090804060608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix a bug in the patches I sent yesterday. Should apply cleanly with
or without the macvlan stuff.


--------------020407050103090804060608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[VLAN]: Fix memset length

Fix sizeof(ETH_ALEN) Introduced by my rtnl_link patches.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 38080b6eda6e5a93a4bd11a5f4a4941d9558d816
tree 4d911975d4b420c372050056f949b3c36595596d
parent 553029f4dd24c41322c3e6cb31458e7e094d21ee
author Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 20:15:00 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 20:15:00 +0200

 net/8021q/vlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 39bdcc2..cda936b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -377,7 +377,7 @@ void vlan_setup(struct net_device *new_dev)
 	new_dev->destructor = free_netdev;
 	new_dev->do_ioctl = vlan_dev_ioctl;
 
-	memset(new_dev->broadcast, 0, sizeof(ETH_ALEN));
+	memset(new_dev->broadcast, 0, ETH_ALEN);
 }
 
 static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)

--------------020407050103090804060608--
