From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove unaligned accesses from
 tcp_get_info()
Date: Wed, 09 Nov 2016 22:51:59 -0500 (EST)
Message-ID: <20161109.225159.834025521838557967.davem@davemloft.net>
References: <20161109.130319.505221196913812307.davem@davemloft.net>
        <1478717921.16809.0.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478719462.16809.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
        ycheng@google.com, soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbcKJDwJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:52:09 -0500
In-Reply-To: <1478719462.16809.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Nov 2016 11:24:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 6ed46d1247a5 ("sock_diag: align nlattr properly when
> needed"), tcp_get_info() gets 64bit aligned memory, so we can avoid
> the unaligned helpers.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nice, applied.

Thanks!
