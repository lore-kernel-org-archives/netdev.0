From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add scheduling point in recvmmsg/sendmmsg
Date: Sun, 10 Jan 2016 22:59:37 -0500 (EST)
Message-ID: <20160110.225937.1492225545440302532.davem@davemloft.net>
References: <1452271040.8255.226.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757949AbcAKD7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:59:39 -0500
In-Reply-To: <1452271040.8255.226.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jan 2016 08:37:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Applications often have to reduce number of datagrams
> they receive or send per system call to avoid starvation problems.
> 
> Really the kernel should take care of this by using cond_resched(),
> so that applications can experiment bigger batch sizes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Seems reasonable, applied, thanks Eric.
