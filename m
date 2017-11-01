From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: addrconf: increment ifp refcount before
 ipv6_del_addr()
Date: Wed, 01 Nov 2017 21:20:01 +0900 (KST)
Message-ID: <20171101.212001.1105354934171345181.davem@davemloft.net>
References: <1509422017.17752.4.camel@edumazet-glaptop3.roam.corp.google.com>
        <f43e1142-e0c6-e2fa-dac8-00579747b91e@gmail.com>
        <1509428829.17752.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932209AbdKAMUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:20:05 -0400
In-Reply-To: <1509428829.17752.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Oct 2017 22:47:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In the (unlikely) event fixup_permanent_addr() returns a failure,
> addrconf_permanent_addr() calls ipv6_del_addr() without the
> mandatory call to in6_ifa_hold(), leading to a refcount error,
> spotted by syzkaller :
 ...
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Ahern <dsahern@gmail.com>

Applied and queued up for -stable.
