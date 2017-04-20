From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 11:50:00 -0400 (EDT)
Message-ID: <20170420.115000.250335491542942036.davem@davemloft.net>
References: <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
        <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
        <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970831AbdDTPuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:50:02 -0400
In-Reply-To: <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 20 Apr 2017 09:27:00 -0400

> The issue Jiri is bringing up is unrelated. He is talking about
> a bitmap and conflating it with a data structure. They are not
> the same issue.

Bitmaps can have the same exact problem as padding if we didn't code
it correctly.

The issue is _purely_, "did we check unused 'fields' and enforce them
to be a certain value"

If not, we lose, and can't use those "fields" in the future.

This rule applies whether you are speaking about padding or a bitmask.
