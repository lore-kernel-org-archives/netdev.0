From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] devlink: rename devlink_eswitch_fill to devlink_nl_eswitch_fill
Date: Thu,  9 Feb 2017 15:54:34 +0100
Message-ID: <1486652076-20756-3-git-send-email-jiri@resnulli.us>
References: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34910 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752252AbdBIO41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:56:27 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so3250344wmu.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:54:41 -0800 (PST)
In-Reply-To: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be aligned with the rest of the file and name the helper function
accordingly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/devlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 7aa8e53..f361924 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1392,9 +1392,9 @@ static int devlink_nl_cmd_sb_occ_max_clear_doit(struct sk_buff *skb,
 	return -EOPNOTSUPP;
 }
 
-static int devlink_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
-				enum devlink_command cmd, u32 portid,
-				u32 seq, int flags)
+static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
+				   enum devlink_command cmd, u32 portid,
+				   u32 seq, int flags)
 {
 	const struct devlink_ops *ops = devlink->ops;
 	void *hdr;
@@ -1450,8 +1450,8 @@ static int devlink_nl_cmd_eswitch_get_doit(struct sk_buff *skb,
 	if (!msg)
 		return -ENOMEM;
 
-	err = devlink_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_GET,
-				   info->snd_portid, info->snd_seq, 0);
+	err = devlink_nl_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_GET,
+				      info->snd_portid, info->snd_seq, 0);
 
 	if (err) {
 		nlmsg_free(msg);
-- 
2.7.4
