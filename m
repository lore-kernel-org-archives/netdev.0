From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH 1/3] odp-util: Fix CT action formating.
Date: Tue, 20 Oct 2015 15:23:58 -0700
Message-ID: <1445379840-113042-1-git-send-email-jrajahalme@nicira.com>
Cc: netdev@vger.kernel.org, jrajahalme@nicira.com
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36671 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbbJTWYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 18:24:12 -0400
Received: by pacfv9 with SMTP id fv9so34709359pac.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 15:24:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comma was missing after "label" attribute.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 lib/odp-util.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index e131e36..8f0f39a 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -590,6 +590,7 @@ format_odp_conntrack_action(struct ds *ds, const struct nlattr *attr)
         if (label) {
             ds_put_format(ds, "label=");
             format_u128(ds, label, label + 1, true);
+            ds_put_char(ds, ',');
         }
         if (helper) {
             ds_put_format(ds, "helper=%s,", helper);
-- 
2.1.4
