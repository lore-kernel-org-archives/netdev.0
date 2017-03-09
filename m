From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use proper lockdep annotation in
 __sk_dst_set()
Date: Wed, 08 Mar 2017 23:14:49 -0800 (PST)
Message-ID: <20170308.231449.687095531271423769.davem@davemloft.net>
References: <1488828235.9415.390.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdCIHPn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 02:15:43 -0500
In-Reply-To: <1488828235.9415.390.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Mar 2017 11:23:55 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> __sk_dst_set() must be called while we own the socket.
> 
> We can get proper lockdep coverage using lockdep_sock_is_held()
> and rcu_dereference_protected()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
