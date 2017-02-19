From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2/net-next] devlink: use DEVLINK_CMD_ESWITCH_* instead of DEVLINK_CMD_ESWITCH_MODE_*
Date: Sun, 19 Feb 2017 15:37:06 +0100
Message-ID: <1487515026-5826-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, ogerlitz@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33239 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdBSOhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 09:37:09 -0500
Received: by mail-wm0-f67.google.com with SMTP id v77so10134829wmv.0
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 06:37:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Sync with kernel and don't use the obsolete enum values.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 34a409f..c357580 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -1303,7 +1303,7 @@ static int cmd_dev_eswitch_show(struct dl *dl)
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_GET,
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_GET,
 			       NLM_F_REQUEST | NLM_F_ACK);
 
 	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, 0);
@@ -1321,7 +1321,7 @@ static int cmd_dev_eswitch_set(struct dl *dl)
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_SET,
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_SET,
 			       NLM_F_REQUEST | NLM_F_ACK);
 
 	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE,
-- 
2.7.4
