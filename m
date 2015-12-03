From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sctp: add rcu protection around np->opt
Date: Thu, 03 Dec 2015 11:32:20 -0500 (EST)
Message-ID: <20151203.113220.516029377541447886.davem@davemloft.net>
References: <20151202.233821.139368757119113563.davem@davemloft.net>
	<1449120948.6379.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<1449121694.6379.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbLCQc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:32:27 -0500
In-Reply-To: <1449121694.6379.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Dec 2015 21:48:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch completes the work I did in commit 45f6fad84cc3
> ("ipv6: add complete rcu protection around np->opt"), as I missed
> sctp part.
> 
> This simply makes sure np->opt is used with proper RCU locking
> and accessors.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
