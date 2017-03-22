From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: frag: release spinlock before calling
 icmp_send()
Date: Wed, 22 Mar 2017 15:41:03 -0700 (PDT)
Message-ID: <20170322.154103.2047938994168800668.davem@davemloft.net>
References: <CACT4Y+ZrHr0Cqw5RPeZ6QW16auOPyKSCOea6AciHBswAT3t14Q@mail.gmail.com>
        <1490198235.16816.172.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753240AbdCVWlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:41:05 -0400
In-Reply-To: <1490198235.16816.172.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Mar 2017 08:57:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported a lockdep splat [1] (false positive) that we can fix
> by releasing the spinlock before calling icmp_send() from ip_expire()
> 
> This is a false positive because sending an ICMP message can not
> possibly re-enter the IP frag engine.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks Eric.
