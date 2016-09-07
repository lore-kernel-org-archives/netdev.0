From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] rtnetlink: remove unused ifla_stats_policy
Date: Wed, 7 Sep 2016 13:57:36 -0700
Message-ID: <20160907135736.7a986302@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34376 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbcIGU51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:57:27 -0400
Received: by mail-pf0-f180.google.com with SMTP id p64so10221942pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 13:57:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure is defined but never used. Flagged with W=1

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/core/rtnetlink.c	2016-09-07 13:55:17.030107744 -0700
+++ b/net/core/rtnetlink.c	2016-09-07 13:55:45.190236855 -0700
@@ -3669,10 +3669,6 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
-	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
-};
-
 static size_t if_nlmsg_stats_size(const struct net_device *dev,
 				  u32 filter_mask)
 {
