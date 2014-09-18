From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 8/8] hack: ofproto: enable odp select action
Date: Thu, 18 Sep 2014 10:52:33 +0900
Message-ID: <1411005153-11041-9-git-send-email-simon.horman@netronome.com>
References: <1411005153-11041-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswtich.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43908 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757328AbaIRBxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:53:09 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so335101pad.21
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:53:09 -0700 (PDT)
In-Reply-To: <1411005153-11041-1-git-send-email-simon.horman@netronome.com>
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
