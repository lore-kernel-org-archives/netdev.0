From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: change big iov allocations
Date: Sat, 21 Apr 2012 16:24:53 -0400 (EDT)
Message-ID: <20120421.162453.1280284976492418010.davem@davemloft.net>
References: <1334945041.2395.243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mikew@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab2DUUY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:24:57 -0400
In-Reply-To: <1334945041.2395.243.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Apr 2012 20:04:01 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> iov of more than 8 entries are allocated in sendmsg()/recvmsg() through
> sock_kmalloc()
> 
> As these allocations are temporary only and small enough, it makes sense
> to use plain kmalloc() and avoid sk_omem_alloc atomic overhead.
> 
> Slightly changed fast path to be even faster.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mike Waychison <mikew@google.com>

Applied, thanks Eric.
