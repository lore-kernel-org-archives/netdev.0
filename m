From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: diag: add support for request sockets to
 tcp_abort()
Date: Fri, 18 Dec 2015 16:07:04 -0500 (EST)
Message-ID: <20151218.160704.660472234205352946.davem@davemloft.net>
References: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965135AbbLRVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:07:06 -0500
In-Reply-To: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Dec 2015 16:14:11 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Adding support for SYN_RECV request sockets to tcp_abort()
> is quite easy after our tcp listener rewrite.
> 
> Note that we also need to better handle listeners, or we might
> leak not yet accepted children, because of a missing
> inet_csk_listen_stop() call.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
