From: Toyo Abe <tabe@miraclelinux.com>
Subject: [PATCH] TUNTAP: Fix wrong debug message
Date: Tue, 25 Dec 2007 10:53:31 +0900
Message-ID: <200712250153.lBP1rVXR004756@dhcp-0176.miraclelinux.com>
Cc: vtun@office.satix.net, maxk@qualcomm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:26951 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbXLYCVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 21:21:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a trivial fix of debug message.
When a persist flag is set, the message should say "enabled".

Signed-off-by: Toyo Abe <tabe@miraclelinux.com>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1f76446..e5a3f5d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -610,7 +610,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 			tun->flags &= ~TUN_PERSIST;
 
 		DBG(KERN_INFO "%s: persist %s\n",
-		    tun->dev->name, arg ? "disabled" : "enabled");
+		    tun->dev->name, (!arg) ? "disabled" : "enabled");
 		break;
 
 	case TUNSETOWNER:
-- 
1.5.3.6

