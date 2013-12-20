From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: fix regression in tc_action_ops
Date: Fri, 20 Dec 2013 17:07:26 -0500 (EST)
Message-ID: <20131220.170726.1944817772969336273.davem@davemloft.net>
References: <CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
	<1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387571552.19078.468.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab3LTWH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:07:28 -0500
In-Reply-To: <1387571552.19078.468.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Dec 2013 12:32:32 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> list_for_each_entry(a, &act_base, head) doesn't
> exit with a = NULL if we reached the end of the list.
> 
> tcf_unregister_action(), tc_lookup_action_n() and tc_lookup_action()
> need fixes.
> 
> Remove tc_lookup_action_id() as its unused and not worth 'fixing'
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 1f747c26c48b ("net_sched: convert tc_action_ops to use struct list_head")

Applied.
