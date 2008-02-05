From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/04]: em_meta: fix compile warning
Date: Tue,  5 Feb 2008 15:29:40 +0100 (MET)
Message-ID: <20080205142903.13543.6864.sendpatchset@localhost.localdomain>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59217 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbYBEO3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:29:41 -0500
In-Reply-To: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: em_meta: fix compile warning

net/sched/em_meta.c: In function 'meta_int_vlan_tag':
net/sched/em_meta.c:179: warning: 'tag' may be used uninitialized in this function

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit adfab462c5e0a32ffff274927bba4eec3afc6e35
tree bfac456798152d7ea6bedcca4a03b4f045605d3d
parent fb1c15ba9ebcab6478a409051ad26d7d180fe286
author Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:21 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:21 +0100

 net/sched/em_meta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 9c2ec19..2a7e648 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -176,7 +176,7 @@ META_COLLECTOR(var_dev)
 
 META_COLLECTOR(int_vlan_tag)
 {
-	unsigned short tag;
+	unsigned short uninitialized_var(tag);
 	if (vlan_get_tag(skb, &tag) < 0)
 		*err = -1;
 	else
