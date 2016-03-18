From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: remove obsolete WARN_ON() in icmp
 handlers
Date: Thu, 17 Mar 2016 21:07:15 -0400 (EDT)
Message-ID: <20160317.210715.1891529884014626450.davem@davemloft.net>
References: <1458193935.7353.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, blazarus@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbcCRBHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 21:07:17 -0400
In-Reply-To: <1458193935.7353.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2016 22:52:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Now SYN_RECV request sockets are installed in ehash table, an ICMP
> handler can find a request socket while another cpu handles an incoming
> packet transforming this SYN_RECV request socket into an ESTABLISHED
> socket.
> 
> We need to remove the now obsolete WARN_ON(req->sk), since req->sk
> is set when a new child is created and added into listener accept queue.
> 
> If this race happens, the ICMP will do nothing special.
> 
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Ben Lazarus <blazarus@google.com>
> Reported-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks Eric.
