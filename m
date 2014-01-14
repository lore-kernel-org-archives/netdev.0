From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] neigh: split lines for NEIGH_VAR_SET so they are not too long
Date: Tue, 14 Jan 2014 15:46:07 +0100
Message-ID: <1389710767-2727-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:45029 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaANOqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:46:13 -0500
Received: by mail-ee0-f52.google.com with SMTP id e53so260612eek.39
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 06:46:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduced by:
commit 1f9248e5606afc6485255e38ad57bdac08fa7711
"neigh: convert parms to an array"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/neighbour.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ea97361..45c5cde 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2086,13 +2086,16 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_ANYCAST_DELAY:
-				NEIGH_VAR_SET(p, ANYCAST_DELAY, nla_get_msecs(tbp[i]));
+				NEIGH_VAR_SET(p, ANYCAST_DELAY,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_PROXY_DELAY:
-				NEIGH_VAR_SET(p, PROXY_DELAY, nla_get_msecs(tbp[i]));
+				NEIGH_VAR_SET(p, PROXY_DELAY,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_LOCKTIME:
-				NEIGH_VAR_SET(p, LOCKTIME, nla_get_msecs(tbp[i]));
+				NEIGH_VAR_SET(p, LOCKTIME,
+					      nla_get_msecs(tbp[i]));
 				break;
 			}
 		}
-- 
1.8.3.1
