From: Jason Wang <jasowang@redhat.com>
Subject: [net-next v4 1/7] tuntap: log the unsigned informaiton with %u
Date: Mon, 29 Oct 2012 13:35:58 +0800
Message-ID: <1351488964-11109-3-git-send-email-jasowang__30678.4397610047$1351489631$gmane$org@redhat.com>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
Cc: maxk@qualcomm.com, haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697Ab2J2FoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 01:44:06 -0400
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
In-Reply-To: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0873cdc..ef13cf0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1422,7 +1422,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	if (!tun)
 		goto unlock;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
+	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %u\n", cmd);
 
 	ret = 0;
 	switch (cmd) {
@@ -1462,7 +1462,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			break;
 		}
 		tun->owner = owner;
-		tun_debug(KERN_INFO, tun, "owner set to %d\n",
+		tun_debug(KERN_INFO, tun, "owner set to %u\n",
 			  from_kuid(&init_user_ns, tun->owner));
 		break;
 
@@ -1474,7 +1474,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			break;
 		}
 		tun->group = group;
-		tun_debug(KERN_INFO, tun, "group set to %d\n",
+		tun_debug(KERN_INFO, tun, "group set to %u\n",
 			  from_kgid(&init_user_ns, tun->group));
 		break;
 
-- 
1.7.1
