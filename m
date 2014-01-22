From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] bonding: change name of sysfs dir for bonding slaves
Date: Wed, 22 Jan 2014 09:05:53 +0100
Message-ID: <1390377957-31466-2-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:41514 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaAVIGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:04 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so4348970eae.33
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:03 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user to identify easily what the attributes are related to. Change
the name of the group to "bonding_slave" to be similar to master which
is named "bonding".

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_sysfs_slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index 7cb97de..84b0e38 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -118,7 +118,7 @@ int bond_sysfs_slave_add(struct slave *slave)
 	int err;
 
 	err = kobject_init_and_add(&slave->kobj, &slave_ktype,
-				   &(slave->dev->dev.kobj), "slave");
+				   &(slave->dev->dev.kobj), "bonding_slave");
 	if (err)
 		return err;
 
-- 
1.8.3.1
