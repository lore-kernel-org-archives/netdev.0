From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Tue, 16 Jan 2007 14:01:59 +0900 (JST)
Message-ID: <20070116.140159.02303722.takamiya@po.ntts.co.jp>
References: <20070116.125728.278729390.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:62261 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932248AbXAPFCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 00:02:10 -0500
To: netdev@vger.kernel.org
In-Reply-To: <20070116.125728.278729390.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  I'm sorry to re-send...

  I think the return value of rt6_nlmsg_size() should includes the
  amount of RTA_METRICS.

  Regards,

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
---
 net/ipv6/route.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c3d568..5f0043c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2017,6 +2017,7 @@ static inline size_t rt6_nlmsg_size(void
 	       + nla_total_size(4) /* RTA_IIF */
 	       + nla_total_size(4) /* RTA_OIF */
 	       + nla_total_size(4) /* RTA_PRIORITY */
+	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
 
-- 
1.4.4

--
Noriaki TAKAMIYA
