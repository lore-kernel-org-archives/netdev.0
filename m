From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Mon, 22 Sep 2014 14:22:00 -0400 (EDT)
Message-ID: <20140922.142200.2003937036676881256.davem@davemloft.net>
References: <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	<CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	<1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, _govind@gmx.com, yinghai@kernel.org,
	netdev@vger.kernel.org, ssujith@cisco.com, gvaradar@cisco.com,
	benve@cisco.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbaIVSWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:22:03 -0400
In-Reply-To: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Sep 2014 08:02:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
> or increasing skb->cb[] size.
> 
> Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
> skb_flow_dissect()") broke IPoIB.
> 
> Only current offender is sch_choke, and this one do not need an
> absolutely precise flow key.
> 
> If we store 17 bytes of flow key, its more than enough. (Its the actual
> size of flow_keys if it was a packed structure, but we might add new
> fields at the end of it later)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in skb_flow_dissect()")

Applied, thanks Eric.
