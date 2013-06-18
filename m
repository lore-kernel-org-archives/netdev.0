From: Dave Jones <davej@redhat.com>
Subject: [PATCH 5/7] sctp: Convert __list_for_each use to list_for_each
Date: Mon, 17 Jun 2013 22:26:52 -0400
Message-ID: <201306180226.r5I2Qq8x010834@gelk.kernelslacker.org>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dave Jones <davej@redhat.com>
---
 net/sctp/protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

netdev: patches 1-4 & 6 are independant to this, and 7 won't be
merged until this one gets to Linus' tree.

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index eaee00c..3b70b76 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -178,7 +178,7 @@ static void sctp_get_local_addr_list(struct net *net)
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		__list_for_each(pos, &sctp_address_families) {
+		list_for_each(pos, &sctp_address_families) {
 			af = list_entry(pos, struct sctp_af, list);
 			af->copy_addrlist(&net->sctp.local_addr_list, dev);
 		}
-- 
1.8.1.4
