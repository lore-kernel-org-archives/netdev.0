From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: trivial: update the comments to reflect the reality
Date: Tue, 28 May 2013 13:26:13 +0200
Message-ID: <1369740373-27712-1-git-send-email-vfalico@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932457Ab3E1LZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 07:25:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3d269a5..f8bee4c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -231,8 +231,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 }
 
 /*
- * Set the slaves in the current bond.  The bond interface must be
- * up for this to succeed.
+ * Set the slaves in the current bond.
  * This is supposed to be only thin wrapper for bond_enslave and bond_release.
  * All hard work should be done there.
  */
@@ -363,7 +362,6 @@ static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
 
 /*
  * Show and set the bonding transmit hash method.
- * The bond interface must be down to change the xmit hash policy.
  */
 static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
-- 
1.7.1
