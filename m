From: jamal <hadi@cyberus.ca>
Subject: [RFC][GENETLINK] introduce command names
Date: Sat, 02 Dec 2006 07:11:36 -0500
Message-ID: <1165061496.3564.11.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-t39vuPjZvUE1XaVFz3pB"
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:62306 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1162975AbWLBMLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 07:11:40 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1671557nze
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 04:11:40 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-t39vuPjZvUE1XaVFz3pB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,
Same as before:
If there is no objections on this approach, please apply this patch.
Against net-2.6.20

cheers,
jamal


--=-t39vuPjZvUE1XaVFz3pB
Content-Disposition: attachment; filename=genl_cmd_name
Content-Type: text/plain; name=genl_cmd_name; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENETLINK] introduce command names

Introduce optional command names.
While command names can be put in user space by the author of the
command, this alleviates things for the discovery process without
requiring any user space code written.
In a recent tutorial that i gave, the desire for this feature was
the highest.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit c3b92488bea3f11a6cc7c1c59101444c26ad12ce
tree 52166fb1ea684e989fef16de89c85fb9bf551bb8
parent b6ac8f41bdd2edd9d215e376efa47261e9b118a1
author Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 07:08:15 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 07:08:15 -0500

 include/net/genetlink.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 7fd131c..52bc278 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -49,6 +49,7 @@ struct genl_info
 /**
  * struct genl_ops - generic netlink operations
  * @cmd: command identifier
+ * @name: command name
  * @flags: flags
  * @policy: attribute validation policy
  * @doit: standard command callback
@@ -58,6 +59,7 @@ struct genl_info
 struct genl_ops
 {
 	u8			cmd;
+	char			name[GENL_NAMSIZ];
 	unsigned int		flags;
 	struct nla_policy	*policy;
 	int		       (*doit)(struct sk_buff *skb,

--=-t39vuPjZvUE1XaVFz3pB--

