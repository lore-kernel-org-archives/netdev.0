From: Jan Engelhardt <jengelh@medozas.de>
Subject: mISDN: fix "persistant" typo
Date: Mon, 4 Apr 2011 01:31:06 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1104040130390.21333@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:42354 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab1DCXbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2011 19:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent fdbba80c7a1638bb2041d6349db27762e951a074 (v2.6.39-rc1-187-gfdbba80)
commit 4d556433b96279a2ca5837a6e9314d9d7bf56a29
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Apr 4 01:30:35 2011 +0200

mISDN: fix "persistant" typo

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 drivers/isdn/mISDN/layer2.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 4ae7505..9e1610f 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -1640,7 +1640,7 @@ l2_tei_remove(struct FsmInst *fi, int event, void *arg)
 }
 
 static void
-l2_st14_persistant_da(struct FsmInst *fi, int event, void *arg)
+l2_st14_persistent_da(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer2 *l2 = fi->userdata;
 	struct sk_buff *skb = arg;
@@ -1654,7 +1654,7 @@ l2_st14_persistant_da(struct FsmInst *fi, int event, void *arg)
 }
 
 static void
-l2_st5_persistant_da(struct FsmInst *fi, int event, void *arg)
+l2_st5_persistent_da(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer2 *l2 = fi->userdata;
 	struct sk_buff *skb = arg;
@@ -1671,7 +1671,7 @@ l2_st5_persistant_da(struct FsmInst *fi, int event, void *arg)
 }
 
 static void
-l2_st6_persistant_da(struct FsmInst *fi, int event, void *arg)
+l2_st6_persistent_da(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer2 *l2 = fi->userdata;
 	struct sk_buff *skb = arg;
@@ -1685,7 +1685,7 @@ l2_st6_persistant_da(struct FsmInst *fi, int event, void *arg)
 }
 
 static void
-l2_persistant_da(struct FsmInst *fi, int event, void *arg)
+l2_persistent_da(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer2 *l2 = fi->userdata;
 	struct sk_buff *skb = arg;
@@ -1829,14 +1829,14 @@ static struct FsmNode L2FnList[] =
 	{ST_L2_6, EV_L2_FRAME_ERROR, l2_frame_error},
 	{ST_L2_7, EV_L2_FRAME_ERROR, l2_frame_error_reest},
 	{ST_L2_8, EV_L2_FRAME_ERROR, l2_frame_error_reest},
-	{ST_L2_1, EV_L1_DEACTIVATE, l2_st14_persistant_da},
+	{ST_L2_1, EV_L1_DEACTIVATE, l2_st14_persistent_da},
 	{ST_L2_2, EV_L1_DEACTIVATE, l2_st24_tei_remove},
 	{ST_L2_3, EV_L1_DEACTIVATE, l2_st3_tei_remove},
-	{ST_L2_4, EV_L1_DEACTIVATE, l2_st14_persistant_da},
-	{ST_L2_5, EV_L1_DEACTIVATE, l2_st5_persistant_da},
-	{ST_L2_6, EV_L1_DEACTIVATE, l2_st6_persistant_da},
-	{ST_L2_7, EV_L1_DEACTIVATE, l2_persistant_da},
-	{ST_L2_8, EV_L1_DEACTIVATE, l2_persistant_da},
+	{ST_L2_4, EV_L1_DEACTIVATE, l2_st14_persistent_da},
+	{ST_L2_5, EV_L1_DEACTIVATE, l2_st5_persistent_da},
+	{ST_L2_6, EV_L1_DEACTIVATE, l2_st6_persistent_da},
+	{ST_L2_7, EV_L1_DEACTIVATE, l2_persistent_da},
+	{ST_L2_8, EV_L1_DEACTIVATE, l2_persistent_da},
 };
 
 static int
-- 
# Created with git-export-patch

