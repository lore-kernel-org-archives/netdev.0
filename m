From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/21] net/atm/atm_sysfs.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:03 -0800
Message-ID: <a1d8d28603edc1ec4284d9c2eaa86fa6311db8bf.1264541548.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1477 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724Ab0AZVkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:22 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add space after for
Indent switch/case statements
80 column wrapping

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/atm_sysfs.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index b5674dc..f693b78 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -42,13 +42,14 @@ static ssize_t show_atmaddress(struct device *cdev,
 
 	spin_lock_irqsave(&adev->lock, flags);
 	list_for_each_entry(aaddr, &adev->local, entry) {
-		for(i = 0, j = 0; i < ATM_ESA_LEN; ++i, ++j) {
+		for (i = 0, j = 0; i < ATM_ESA_LEN; ++i, ++j) {
 			if (j == *fmt) {
 				pos += sprintf(pos, ".");
 				++fmt;
 				j = 0;
 			}
-			pos += sprintf(pos, "%02x", aaddr->addr.sas_addr.prv[i]);
+			pos += sprintf(pos, "%02x",
+				       aaddr->addr.sas_addr.prv[i]);
 		}
 		pos += sprintf(pos, "\n");
 	}
@@ -78,17 +79,17 @@ static ssize_t show_link_rate(struct device *cdev,
 
 	/* show the link rate, not the data rate */
 	switch (adev->link_rate) {
-		case ATM_OC3_PCR:
-			link_rate = 155520000;
-			break;
-		case ATM_OC12_PCR:
-			link_rate = 622080000;
-			break;
-		case ATM_25_PCR:
-			link_rate = 25600000;
-			break;
-		default:
-			link_rate = adev->link_rate * 8 * 53;
+	case ATM_OC3_PCR:
+		link_rate = 155520000;
+		break;
+	case ATM_OC12_PCR:
+		link_rate = 622080000;
+		break;
+	case ATM_25_PCR:
+		link_rate = 25600000;
+		break;
+	default:
+		link_rate = adev->link_rate * 8 * 53;
 	}
 	pos += sprintf(pos, "%d\n", link_rate);
 
-- 
1.6.6.rc0.57.gad7a

