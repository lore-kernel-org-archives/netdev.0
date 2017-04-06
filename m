From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: uapi: use hex numbers for NLM_F_* flags
Date: Thu,  6 Apr 2017 16:10:42 +0200
Message-ID: <20170406141042.30309-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35134 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934646AbdDFOKt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 10:10:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It's rather confusing that the netlink message flags are
numbered 1, 2, 4, 8, 16, 32, <unused>, 0x100. Make that
more understandable by numbering the lower ones with hex
constants as well.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/uapi/linux/netlink.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index f3946a27bd07..b2c9c26ea30f 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -50,12 +50,12 @@ struct nlmsghdr {
 
 /* Flags values */
 
-#define NLM_F_REQUEST		1	/* It is request message. 	*/
-#define NLM_F_MULTI		2	/* Multipart message, terminated by NLMSG_DONE */
-#define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
-#define NLM_F_ECHO		8	/* Echo this request 		*/
-#define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
-#define NLM_F_DUMP_FILTERED	32	/* Dump was filtered as requested */
+#define NLM_F_REQUEST		0x01	/* It is request message. 	*/
+#define NLM_F_MULTI		0x02	/* Multipart message, terminated by NLMSG_DONE */
+#define NLM_F_ACK		0x04	/* Reply with ack, with zero or error code */
+#define NLM_F_ECHO		0x08	/* Echo this request 		*/
+#define NLM_F_DUMP_INTR		0x10	/* Dump was inconsistent due to sequence change */
+#define NLM_F_DUMP_FILTERED	0x20	/* Dump was filtered as requested */
 
 /* Modifiers to GET request */
 #define NLM_F_ROOT	0x100	/* specify tree	root	*/
-- 
2.11.0
