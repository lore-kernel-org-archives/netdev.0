From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] sched: add missing curly braces in else branch in tc_ctl_tfilter
Date: Thu,  9 Feb 2017 14:38:59 +0100
Message-ID: <1486647540-14656-6-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33697 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdBINr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:47:58 -0500
Received: by mail-wr0-f196.google.com with SMTP id i10so12007249wrb.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:47:27 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Curly braces need to be there, for stylistic reasons.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index f44378c..48864ad 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -315,8 +315,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 					err = -EINVAL;
 					goto errout;
 				}
-			} else
+			} else {
 				tp = NULL;
+			}
 			break;
 		}
 	}
-- 
2.7.4
