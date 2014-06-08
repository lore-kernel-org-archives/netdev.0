From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: force a list_del() in
 unregister_netdevice_many()
Date: Sun, 08 Jun 2014 14:15:31 -0700 (PDT)
Message-ID: <20140608.141531.1369298233316729957.davem@davemloft.net>
References: <CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>
	<1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbaFHVPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 17:15:32 -0400
In-Reply-To: <1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jun 2014 06:44:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> unregister_netdevice_many() API is error prone and we had too
> many bugs because of dangling LIST_HEAD on stacks.
> 
> See commit f87e6f47933e3e ("net: dont leave active on stack LIST_HEAD")
> 
> In fact, instead of making sure no caller leaves an active list_head,
> just force a list_del() in the callee. No one seems to need to access
> the list after unregister_netdevice_many()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> I based this patch on net-next, but it seems to close existing bugs,
> so its probably a stable candidate.

It applied cleanly to net so I applied it there and will queue up for -stable,
thanks.
