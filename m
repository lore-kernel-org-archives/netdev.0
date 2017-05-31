From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rtnetlink: bail out from rtnl_fdb_dump() on parse
 error
Date: Wed, 31 May 2017 11:10:25 -0400 (EDT)
Message-ID: <20170531.111025.1574581950547485984.davem@davemloft.net>
References: <20170523112028.132630-1-glider@google.com>
        <20170524.153224.1230164587077679673.davem@davemloft.net>
        <CAG_fn=WNnkmZ8CXqM6w7p_kmhh8Tys1HjgkfASYjvEZ2iie0hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbdEaPK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:10:27 -0400
In-Reply-To: <CAG_fn=WNnkmZ8CXqM6w7p_kmhh8Tys1HjgkfASYjvEZ2iie0hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Wed, 31 May 2017 10:56:47 +0200

> Hi David,
> 
> I've noticed that the upstream patch:
> https://github.com/torvalds/linux/commit/0ff50e83b5122e836ca492fefb11656b225ac29c
> contains the KMSAN report and the repro, despite I've put them under
> the triple dash (IIRC Eric told me I shouldn't bloat the patch
> descriptions with that information). Did I mess it up somehow?

I put them into the main commit log message by hand when I applied the
patch, I think the more information in commit log messages the better.
