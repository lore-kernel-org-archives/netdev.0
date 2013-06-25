From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add include file to suppress sparse
 warnings
Date: Tue, 25 Jun 2013 02:44:48 -0700 (PDT)
Message-ID: <20130625.024448.2140346947626121222.davem@davemloft.net>
References: <1372149011.3301.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab3FYJot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 05:44:49 -0400
In-Reply-To: <1372149011.3301.88.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Jun 2013 01:30:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit f88c91ddba95 ("ipv6: statically link
> register_inet6addr_notifier()" added following sparse warnings :
> 
> net/ipv6/addrconf_core.c:83:5: warning: symbol
> 'register_inet6addr_notifier' was not declared. Should it be static?
> net/ipv6/addrconf_core.c:89:5: warning: symbol
> 'unregister_inet6addr_notifier' was not declared. Should it be static?
> net/ipv6/addrconf_core.c:95:5: warning: symbol
> 'inet6addr_notifier_call_chain' was not declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
