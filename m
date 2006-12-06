From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][GENETLINK]  Update generic netlink header
Date: Wed, 06 Dec 2006 12:08:24 -0500
Message-ID: <1165424904.3749.11.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-G5aQ1Sant7e0g5//Q2U0"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:38752 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936478AbWLFRIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:08:30 -0500
Received: by wr-out-0506.google.com with SMTP id i7so410118wra
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 09:08:30 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-G5aQ1Sant7e0g5//Q2U0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stepehen,

Didnt hear back from you, please apply this one; needed for the next
patches.

cheers,
jamal

--=-G5aQ1Sant7e0g5//Q2U0
Content-Disposition: attachment; filename=genl-p2
Content-Type: text/plain; name=genl-p2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENL]  Update generic netlink header

The header file needs to be uptodate with recent changes to allow
for forward compatibility

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 515370c958be14b417e20611258eecbe9fda2382
tree 5d81c1d7a50592a18c50948a65faf3b85cefd9a7
parent ae665a522bd46bea44c5ea84c89c8b1731954170
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 11:32:37 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 11:32:37 -0500

 include/linux/genetlink.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 9049dc6..f7a9377 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -17,6 +17,9 @@ struct genlmsghdr {
 #define GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct genlmsghdr))
 
 #define GENL_ADMIN_PERM		0x01
+#define GENL_CMD_CAP_DO		0x02
+#define GENL_CMD_CAP_DUMP	0x04
+#define GENL_CMD_CAP_HASPOL	0x08
 
 /*
  * List of reserved static generic netlink identifiers:
@@ -58,9 +61,6 @@ enum {
 	CTRL_ATTR_OP_UNSPEC,
 	CTRL_ATTR_OP_ID,
 	CTRL_ATTR_OP_FLAGS,
-	CTRL_ATTR_OP_POLICY,
-	CTRL_ATTR_OP_DOIT,
-	CTRL_ATTR_OP_DUMPIT,
 	__CTRL_ATTR_OP_MAX,
 };
 

--=-G5aQ1Sant7e0g5//Q2U0--

