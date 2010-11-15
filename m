From: David Miller <davem@davemloft.net>
Subject: vlan: Fix build warning in vlandev_seq_show()
Date: Mon, 15 Nov 2010 10:38:39 -0800 (PST)
Message-ID: <20101115.103839.200362428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757885Ab0KOSiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:38:14 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 40BDF24C088
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 10:38:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/8021q/vlanproc.c: In function 'vlandev_seq_show':
net/8021q/vlanproc.c:283:20: warning: unused variable 'fmt'

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/8021q/vlanproc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 8a64db1..d1314cf 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -280,7 +280,6 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
-	static const char fmt[] = "%30s %12lu\n";
 	static const char fmt64[] = "%30s %12llu\n";
 	int i;
 
-- 
1.7.3.2

