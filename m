From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/8] drop_monitor: make genl_multicast_group const
Date: Wed, 31 Aug 2016 15:15:23 -0700
Message-ID: <20160831151523.7d8e3d73@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36255 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcIAGZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:08 -0400
Received: by mail-pa0-f49.google.com with SMTP id fu3so18676945pad.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:07 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/core/drop_monitor.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index d6b3b57..72cfb0c 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -105,7 +105,7 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	return skb;
 }
 
-static struct genl_multicast_group dropmon_mcgrps[] = {
+static const struct genl_multicast_group dropmon_mcgrps[] = {
 	{ .name = "events", },
 };
 
-- 
2.9.3
