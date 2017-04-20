From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 11:23:40 -0400 (EDT)
Message-ID: <20170420.112340.1425759737710664373.davem@davemloft.net>
References: <20170419161736.GJ3357@nanopsycho.orion>
        <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
        <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970445AbdDTPXm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:23:42 -0400
In-Reply-To: <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Apr 2017 05:18:14 -0700

> By changing the kernel and recognizing new flags in existing padding,
> you might break the programs.
> 
> This is not acceptable. Period.
> 
> Had we checked the padding being 0 in old kernels, this change would
> have been possible today.

I completely agree.
