From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: mld: Prevent skb_over_panic with large MTUs
Date: Sat, 21 Dec 2013 22:21:03 -0500 (EST)
Message-ID: <20131221.222103.578188799701348317.davem@davemloft.net>
References: <1387587610-31723-1-git-send-email-travisb@aristanetworks.com>
	<1387589098.19078.489.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: travisb@aristanetworks.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab3LVDVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 22:21:05 -0500
In-Reply-To: <1387589098.19078.489.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Dec 2013 17:24:58 -0800

> Or even better use skb_availroom() as we do in TCP stack...
> (check sk_stream_alloc_skb())

Agreed, use something like skb_availroom() instead of an ad-hoc
piece of control block state.
