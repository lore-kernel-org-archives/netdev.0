From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 15:44:20 -0700 (PDT)
Message-ID: <20050728.154420.21594218.davem@davemloft.net>
References: <42E94680.8060309@cosmosbay.com>
	<20050728.135826.63129319.davem@davemloft.net>
	<42E94D11.4090002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42E94D11.4090002@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Jul 2005 23:24:33 +0200

> On a dual opteron machine, this thing from ip_route_input() is very expensive :
> 
>   RT_CACHE_STAT_INC(in_hlist_search);

That's amazing since it's per-cpu.  I don't have any suggestions
besides your idea to increment it once using an accumulation local
variable.
