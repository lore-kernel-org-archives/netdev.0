From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/8] bonding: Purely cosmetic: rename a local variable
Date: Thu,  6 Dec 2007 23:40:30 -0800
Message-ID: <1197013237259-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Wagner Ferenc <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:50960 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbXLGHkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:49 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77ecJ3009084
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:38 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77ecS0118826
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:38 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77ecUH018038
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:38 -0700
In-Reply-To: <11970132372293-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wagner Ferenc <wferi@niif.hu>

From: Wagner Ferenc <wferi@niif.hu>

Code for rendering multivalue sysfs files occurs three times
in this module.  Rename 'buffer' to 'buf' in the first, for
the sake of consistency.

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6bb91e2..5c31f5c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -74,7 +74,7 @@ struct rw_semaphore bonding_rwsem;
  * "show" function for the bond_masters attribute.
  * The class parameter is ignored.
  */
-static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
+static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 {
 	int res = 0;
 	struct bonding *bond;
@@ -86,13 +86,12 @@ static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res = PAGE_SIZE - 10;
-			res += sprintf(buffer + res, "++more++ ");
+			res += sprintf(buf + res, "++more++ ");
 			break;
 		}
-		res += sprintf(buffer + res, "%s ",
-			       bond->dev->name);
+		res += sprintf(buf + res, "%s ", bond->dev->name);
 	}
-	if (res) buffer[res-1] = '\n'; /* eat the leftover space */
+	if (res) buf[res-1] = '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
-- 
1.5.3.4.206.g58ba4-dirty

