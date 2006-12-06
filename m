From: jamal <hadi@cyberus.ca>
Subject: [PATCH][GENETLINK] fix misplaced command flags
Date: Wed, 06 Dec 2006 12:02:23 -0500
Message-ID: <1165424543.3749.2.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-T5wbtE8222CBLupfNp7e"
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:35898 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936919AbWLFRC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:02:28 -0500
Received: by wr-out-0506.google.com with SMTP id i7so407921wra
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 09:02:27 -0800 (PST)
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-T5wbtE8222CBLupfNp7e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


fixes something i broke in previous patch. Against net-2.6.20.
BTW, is it just me having problems syncing net-2.6.20?

cheers,
jamal

--=-T5wbtE8222CBLupfNp7e
Content-Disposition: attachment; filename=genl-flags-p
Content-Type: text/plain; name=genl-flags-p; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENETLINK] fix misplaced command flags

The command flags for dump and do were swapped..

Signed-off-by: Jamal Hadi Salim<hadi@cyberus.ca>

---
commit 03b09fc1e8f71a14c661af496941b6de963fddf1
tree 3b3c62e1b5f1db0e75ab383a2ec43173cb0f0efa
parent 49ba7537cec41f0db2500054b5fde3c193c37a97
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 11:58:34 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 11:58:34 -0500

 net/netlink/genetlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 3e37ea5..a59b7bb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -144,9 +144,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	}
 
 	if (ops->dumpit)
-		ops->flags |= GENL_CMD_CAP_DO;
-	if (ops->doit)
 		ops->flags |= GENL_CMD_CAP_DUMP;
+	if (ops->doit)
+		ops->flags |= GENL_CMD_CAP_DO;
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 

--=-T5wbtE8222CBLupfNp7e--

