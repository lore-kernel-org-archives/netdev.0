From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: better IP_MAX_MTU enforcement
Date: Wed, 16 Aug 2017 16:29:25 -0700 (PDT)
Message-ID: <20170816.162925.2199453201191784671.davem@davemloft.net>
References: <1502906952.4936.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdHPX3Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:29:25 -0400
In-Reply-To: <1502906952.4936.140.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Aug 2017 11:09:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While working on yet another syzkaller report, I found
> that our IP_MAX_MTU enforcements were not properly done.
> 
> gcc seems to reload dev->mtu for min(dev->mtu, IP_MAX_MTU), and
> final result can be bigger than IP_MAX_MTU :/
> 
> This is a problem because device mtu can be changed on other cpus or
> threads.
> 
> While this patch does not fix the issue I am working on, it is
> probably worth addressing it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Also applied and queued up for -stable.

Thanks.
