From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: give visibility to mq slave qdiscs
Date: Mon, 09 Dec 2013 19:55:19 -0500 (EST)
Message-ID: <20131209.195519.1782933721679697565.davem@davemloft.net>
References: <1386270722.30495.210.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376Ab3LJAzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 19:55:23 -0500
In-Reply-To: <1386270722.30495.210.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 11:12:02 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
> added the ability to change default qdisc from pfifo_fast to say fq
> 
> But as most modern ethernet devices are multiqueue, we cant really
> see all the statistics from "tc -s qdisc show", as the default root
> qdisc is mq.
> 
> This patch adds the calls to qdisc_list_add() to mq and mqprio
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
