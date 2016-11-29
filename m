From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] macvtap: replace printk with netdev_err
Date: Tue, 29 Nov 2016 11:26:32 +0800
Message-ID: <1480389992-69609-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:51946 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbcK2D0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 22:26:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces printk() with netdev_err() for macvtap device.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/macvtap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5da9861..2513939 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -437,7 +437,7 @@ static int macvtap_get_minor(struct macvlan_dev *vlan)
 	if (retval >= 0) {
 		vlan->minor = retval;
 	} else if (retval == -ENOSPC) {
-		printk(KERN_ERR "too many macvtap devices\n");
+		netdev_err(vlan->dev, "Too many macvtap devices\n");
 		retval = -EINVAL;
 	}
 	mutex_unlock(&minor_lock);
-- 
1.8.3.1
