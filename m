From: fgao@ikuai8.com
Subject: [PATCH 1/1] net: vlan: Use sizeof instead of literal number
Date: Tue, 18 Oct 2016 08:44:02 +0800
Message-ID: <1476751442-12112-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:41768 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934089AbcJRAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 20:45:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Use sizeof variable instead of literal number to enhance the readability.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/8021q/vlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8de138d..5a3903b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -515,8 +515,8 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		return -EFAULT;
 
 	/* Null terminate this sucker, just in case. */
-	args.device1[23] = 0;
-	args.u.device2[23] = 0;
+	args.device1[sizeof(args.device1) - 1] = 0;
+	args.u.device2[sizeof(args.u.device2) - 1] = 0;
 
 	rtnl_lock();
 
-- 
1.9.1
