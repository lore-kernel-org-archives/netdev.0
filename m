From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 12:07:19 -0400 (EDT)
Message-ID: <20170421.120719.110454615745765701.davem@davemloft.net>
References: <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
        <1492788031.6453.14.camel@edumazet-glaptop3.roam.corp.google.com>
        <6b26ef20-972f-24bf-22bf-8462606ce16d@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161852AbdDURCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:02:36 -0400
In-Reply-To: <6b26ef20-972f-24bf-22bf-8462606ce16d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 21 Apr 2017 11:40:00 -0400

> Eric: Your are speaking in generalities and you starting premise is
> wrong.

I disagree.

If we never checked, it is our problem and our issue.  Not that of
the user.

If you want to start checking and verifying new attribute bitmasks
now, great!  But we are stuck in the case of existing bitmasks
and pads because we did not do so at the time we released them
into the wild.
