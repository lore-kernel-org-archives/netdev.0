From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: tcp: fix panic in SYN processing
Date: Wed, 23 Nov 2011 15:49:55 -0500 (EST)
Message-ID: <20111123.154955.253837848372352962.davem@davemloft.net>
References: <1322048036.17693.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab1KWUt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 15:49:58 -0500
In-Reply-To: <1322048036.17693.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2011 12:33:56 +0100

> commit 72a3effaf633bc ([NET]: Size listen hash tables using backlog
> hint) added a bug allowing inet6_synq_hash() to return an out of bound
> array index, because of u16 overflow.
> 
> Bug can happen if system admins set net.core.somaxconn &
> net.ipv4.tcp_max_syn_backlog sysctls to values greater than 65536
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Good catch, applied and queued up for -stable.

Thanks!
