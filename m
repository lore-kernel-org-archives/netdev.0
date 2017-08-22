From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: use kvmalloc() for class hash
 tables
Date: Tue, 22 Aug 2017 14:38:04 -0700 (PDT)
Message-ID: <20170822.143804.1423134731734526975.davem@davemloft.net>
References: <1503430006.2499.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdHVViF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:38:05 -0400
In-Reply-To: <1503430006.2499.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Aug 2017 12:26:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> High order GFP_KERNEL allocations can stress the host badly.
> 
> Use modern kvmalloc_array()/kvfree() instead of custom
> allocations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
