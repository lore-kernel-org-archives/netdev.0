From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] switchdev: fix typo in comments/doc
Date: Thu, 24 Mar 2016 16:50:00 +0100
Message-ID: <1458834600-5395-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:50865 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcCXPuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:50:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor typo.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/networking/switchdev.txt | 2 +-
 net/switchdev/switchdev.c              | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index fad63136ee3e..2f659129694b 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -386,7 +386,7 @@ used. First phase is to "prepare" anything needed, including various checks,
 memory allocation, etc. The goal is to handle the stuff that is not unlikely
 to fail here. The second phase is to "commit" the actual changes.
 
-Switchdev provides an inftrastructure for sharing items (for example memory
+Switchdev provides an infrastructure for sharing items (for example memory
 allocations) between the two phases.
 
 The object created by a driver in "prepare" phase and it is queued up by:
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8b5833c1ff2e..2b9b98f1c2ff 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1079,7 +1079,7 @@ nla_put_failure:
  *	@filter_dev: filter device
  *	@idx:
  *
- *	Delete FDB entry from switch device.
+ *	Dump FDB entries from switch device.
  */
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
-- 
2.4.2
