From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test4 SEQ_START_TOKEN drivers/md (4/6)
Date: Fri, 05 Sep 2003 18:47:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062812862.16851.169.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test4/drivers/md/md.c SEQ_START_TOKEN/drivers/md/md.c
-- linux-2.6.0-test4/drivers/md/md.c	2003-09-02 12:52:39.000000000 -0700
+++ SEQ_START_TOKEN/drivers/md/md.c	2003-09-04 19:50:46.000000000 -0700
@@ -2858,7 +2858,7 @@
 		return NULL;
 	if (!l--)
 		/* header */
-		return (void*)1;
+		return SEQ_START_TOKEN;
 
 	spin_lock(&all_mddevs_lock);
 	list_for_each(tmp,&all_mddevs)
@@ -2884,7 +2884,7 @@
 		return NULL;
 
 	spin_lock(&all_mddevs_lock);
-	if (v == (void*)1)
+	if (v == SEQ_START_TOKEN)
 		tmp = all_mddevs.next;
 	else
 		tmp = mddev->all_mddevs.next;
@@ -2896,7 +2896,7 @@
 	}		
 	spin_unlock(&all_mddevs_lock);
 
-	if (v != (void*)1)
+	if (v != SEQ_START_TOKEN)
 		mddev_put(mddev);
 	return next_mddev;
 
@@ -2906,7 +2906,7 @@
 {
 	mddev_t *mddev = v;
 
-	if (mddev && v != (void*)1 && v != (void*)2)
+	if (mddev && v != SEQ_START_TOKEN && v != (void*)2)
 		mddev_put(mddev);
 }
 
@@ -2918,7 +2918,7 @@
 	mdk_rdev_t *rdev;
 	int i;
 
-	if (v == (void*)1) {
+	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "Personalities : ");
 		spin_lock(&pers_lock);
 		for (i = 0; i < MAX_PERSONALITY; i++)
