From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: keep original skb ownership
Date: Fri, 07 Mar 2014 14:38:10 -0500 (EST)
Message-ID: <20140307.143810.1279346177085156779.davem@davemloft.net>
References: <1394072374.27473.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, tparkin@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaCGTiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:38:12 -0500
In-Reply-To: <1394072374.27473.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Mar 2014 18:19:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> There is no reason to orphan skb in l2tp.
> 
> This breaks things like per socket memory limits, TCP Small queues...
> 
> Fix this before more people copy/paste it.
> 
> This is very similar to commit 8f646c922d550
> ("vxlan: keep original skb ownership")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: James Chapman <jchapman@katalix.com>

Ok applied, thanks Eric.
