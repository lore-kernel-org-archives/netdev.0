From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] inet_diag: fix possible overflow in
 inet_diag_dump_one_icsk()
Date: Fri, 13 Mar 2015 15:55:00 -0400 (EDT)
Message-ID: <20150313.155500.725084979936385610.davem@davemloft.net>
References: <1426262994.11398.188.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426265399.11398.190.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030338AbbCMTzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:55:02 -0400
In-Reply-To: <1426265399.11398.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Mar 2015 09:49:59 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> inet_diag_dump_one_icsk() allocates too small skb.
> 
> Add inet_sk_attr_size() helper right before inet_sk_diag_fill()
> so that it can be updated if/when new attributes are added.
> 
> iproute2/ss currently does not use this dump_one() interface,
> this might explain nobody noticed this problem yet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: added missing 'static' qualifier

Applied and queued up for -stable, thanks Eric.
