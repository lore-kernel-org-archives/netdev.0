From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 1/5] sctp: Add some missing types for debug message
Date: Mon,  2 Mar 2009 14:46:10 -0500
Message-ID: <1236023174-18314-2-git-send-email-vladislav.yasevich@hp.com>
References: <>
 <1236023174-18314-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:16188 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbZCBTqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:46:21 -0500
In-Reply-To: <1236023174-18314-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

This patch add the type name "AUTH" and primitive type name
"PRIMITIVE_ASCONF" for debug message.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/debug.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 67715f4..7ff548a 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -86,6 +86,9 @@ const char *sctp_cname(const sctp_subtype_t cid)
 	case SCTP_CID_FWD_TSN:
 		return "FWD_TSN";
 
+	case SCTP_CID_AUTH:
+		return "AUTH";
+
 	default:
 		break;
 	}
@@ -135,6 +138,7 @@ static const char *sctp_primitive_tbl[SCTP_NUM_PRIMITIVE_TYPES] = {
 	"PRIMITIVE_ABORT",
 	"PRIMITIVE_SEND",
 	"PRIMITIVE_REQUESTHEARTBEAT",
+	"PRIMITIVE_ASCONF",
 };
 
 /* Lookup primitive debug name. */
-- 
1.5.4.3

