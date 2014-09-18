From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 8/8] hack: ofproto: enable odp select action
Date: Thu, 18 Sep 2014 10:55:11 +0900
Message-ID: <1411005311-11752-9-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:47689 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757362AbaIRB6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:58:00 -0400
Received: by mail-pa0-f51.google.com with SMTP id eu11so339612pac.38
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:58:00 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a quick hack to enable the datapath group select action.
It is in lieu of some combination of:
* probing
* run-time configuration by the end-use.
* run-time heuristic to use the action as appropriate

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 ofproto/ofproto-dpif-xlate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index b08a821..eca617d 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -2896,7 +2896,7 @@ xlate_select_group_userspace(struct xlate_ctx *ctx, struct group_dpif *group)
 static void
 xlate_select_group(struct xlate_ctx *ctx, struct group_dpif *group)
 {
-    if (ctx->xbridge->dp_select_group) {
+    if (true /*ctx->xbridge->dp_select_group*/ ) {
         xlate_select_group_datapath(ctx, group);
     } else {
         xlate_select_group_userspace(ctx, group);
-- 
2.0.1
