From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ping: implement proper locking
Date: Fri, 24 Mar 2017 20:51:04 -0700 (PDT)
Message-ID: <20170324.205104.1461669236183327007.davem@davemloft.net>
References: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170324.191016.1704224805339195329.davem@davemloft.net>
        <1490409373.24891.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, solar@openwall.com, andreyknvl@google.com,
        edumazet@google.com, danieljiang0415@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966059AbdCYDvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 23:51:06 -0400
In-Reply-To: <1490409373.24891.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Mar 2017 19:36:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We got a report of yet another bug in ping
> 
> http://www.openwall.com/lists/oss-security/2017/03/24/6
> 
> ->disconnect() is not called with socket lock held.
> 
> Fix this by acquiring ping rwlock earlier.
> 
> Thanks to Daniel, Alexander and Andrey for letting us know this problem.
> 
> Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Daniel Jiang <danieljiang0415@gmail.com>
> Reported-by: Solar Designer <solar@openwall.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
