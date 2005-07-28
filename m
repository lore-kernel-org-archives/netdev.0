From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 12:39:22 -0700 (PDT)
Message-ID: <20050728.123922.126777020.davem@davemloft.net>
References: <20050704.160140.21591849.davem@davemloft.net>
	<42CA390C.9000801@cosmosbay.com>
	<42E8FF24.9070009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42E8FF24.9070009@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Jul 2005 17:52:04 +0200

> [NET] : Adds prefetches in route hash list traversals.
>
> The actual code doesnt use a prefetch enabled macro like
> list_for_each_rcu(), so manually add prefetch() hints.

and the measured performance improvement is?
