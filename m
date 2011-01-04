From: Francois-Xavier Le Bail <fx.lebail@orange.fr>
Subject: [PATCH v2] net: typos in comments in include/linux/igmp.h
Date: Tue, 04 Jan 2011 20:10:20 +0100
Message-ID: <4D23709C.1040408@orange.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from msa02.smtpout.orange.fr ([193.252.23.211]:50919 "EHLO
	msa.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab1ADTRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 14:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are typos in comments in include/linux/igmp.h:

83 #define IGMP_HOST_MEMBERSHIP_QUERY      0x11    /* From RFC1112 */
84 #define IGMP_HOST_MEMBERSHIP_REPORT     0x12    /* Ditto */
[snip]
88 #define IGMPV2_HOST_MEMBERSHIP_REPORT   0x16    /* V2 version of 0x11 */
89 #define IGMP_HOST_LEAVE_MESSAGE         0x17
90 #define IGMPV3_HOST_MEMBERSHIP_REPORT   0x22    /* V3 version of 0x11 */

The line 88 and 90 are about REPORT messages.
The IGMP_HOST_MEMBERSHIP_REPORT (IGMP V1) value is 0x12.
So the comment on line 88 must be /* V2 version of 0x12 */,
and the comment on line 90 must be /* V3 version of 0x12 */.

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@orange.fr>

---

diff -ru a/include/linux/igmp.h b/include/linux/igmp.h
--- a/include/linux/igmp.h	2010-08-27 01:47:12.000000000 +0200
+++ b/include/linux/igmp.h	2010-12-15 09:50:47.808363144 +0100
@@ -85,9 +85,9 @@
 #define IGMP_DVMRP			0x13	/* DVMRP routing */
 #define IGMP_PIM			0x14	/* PIM routing */
 #define IGMP_TRACE			0x15
-#define IGMPV2_HOST_MEMBERSHIP_REPORT	0x16	/* V2 version of 0x11 */
+#define IGMPV2_HOST_MEMBERSHIP_REPORT	0x16	/* V2 version of 0x12 */
 #define IGMP_HOST_LEAVE_MESSAGE 	0x17
-#define IGMPV3_HOST_MEMBERSHIP_REPORT	0x22	/* V3 version of 0x11 */
+#define IGMPV3_HOST_MEMBERSHIP_REPORT	0x22	/* V3 version of 0x12 */
 
 #define IGMP_MTRACE_RESP		0x1e
 #define IGMP_MTRACE			0x1f
