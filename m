From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: fix a regression in
 tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 17:07:19 -0500 (EST)
Message-ID: <20131220.170719.891308455550177267.davem@davemloft.net>
References: <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab3LTWHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:07:20 -0500
In-Reply-To: <1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Dec 2013 10:04:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> list_for_each_entry(t, &tcf_proto_base, head) doesn't
> exit with t = NULL if we reached the end of the list.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 3627287463b4 ("net_sched: convert tcf_proto_ops to use struct 
> list_head")
> Cc: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
