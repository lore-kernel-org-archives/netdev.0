From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/8] bonding: Coding style: break line after the if condition
Date: Thu,  6 Dec 2007 23:40:31 -0800
Message-ID: <11970132382296-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
 <1197013237259-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Wagner Ferenc <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52166 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbXLGHku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:50 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77edgj012093
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:39 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77edxP130724
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:39 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77ecmB018064
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:39 -0700
In-Reply-To: <1197013237259-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wagner Ferenc <wferi@niif.hu>

From: Wagner Ferenc <wferi@niif.hu>

Adhere to coding style: break line after the if condition

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 5c31f5c..9de2c52 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -91,7 +91,8 @@ static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 		}
 		res += sprintf(buf + res, "%s ", bond->dev->name);
 	}
-	if (res) buf[res-1] = '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
@@ -239,7 +240,8 @@ static ssize_t bonding_show_slaves(struct device *d,
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
 	read_unlock(&bond->lock);
-	if (res) buf[res-1] = '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
 	return res;
 }
 
@@ -705,7 +707,8 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 			res += sprintf(buf + res, "%u.%u.%u.%u ",
 			       NIPQUAD(bond->params.arp_targets[i]));
 	}
-	if (res) buf[res-1] = '\n'; /* eat the leftover space */
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
 	return res;
 }
 
-- 
1.5.3.4.206.g58ba4-dirty

