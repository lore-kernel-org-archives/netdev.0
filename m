From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix potential crash in __netdev_pick_tx()
Date: Thu, 09 Jul 2015 22:49:21 -0700 (PDT)
Message-ID: <20150709.224921.97621113448468249.davem@davemloft.net>
References: <559A3B9C.90905@oracle.com>
	<1436179279.25714.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<1436460967.24939.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bob.liu@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbGJFtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 01:49:24 -0400
In-Reply-To: <1436460967.24939.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jul 2015 18:56:07 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
> fixed an issue in normal forward path, caused by sender_cpu & napi_id
> skb fields being an union.
> 
> Bridge is another point where skb can be forwarded, so we need
> the same cure.
> 
> Bug triggers if packet was received on a NIC using skb_mark_napi_id()
> 
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Bob Liu <bob.liu@oracle.com>
> Tested-by: Bob Liu <bob.liu@oracle.com>

Applied and queued up for -stable, thanks.
