From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] sched: act: ife: UAPI checks and
 performance tweaks
Date: Thu, 12 Oct 2017 22:23:17 -0700 (PDT)
Message-ID: <20171012.222317.639552348780320377.davem@davemloft.net>
References: <20171011211608.22692-1-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, eric.dumazet@gmail.com, bjb@mojatatu.com
To: aring@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdJMFXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 01:23:18 -0400
In-Reply-To: <20171011211608.22692-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <aring@mojatatu.com>
Date: Wed, 11 Oct 2017 17:16:05 -0400

> this patch series contains at first a patch which adds a check for
> IFE_ENCODE and IFE_DECODE when a ife act gets created or updated and adding
> handling of these cases only inside the act callback only.
> 
> The second patch use per-cpu counters and move the spinlock around so that
> the spinlock is less being held in act callback.
> 
> The last patch use rcu for update parameters and also move the spinlock for
> the same purpose as in patch 2.
> 
> Notes:
>  - There is still a spinlock around for protecting the metalist and a
>    rw-lock for another list. Should be migrated to a rcu list, ife
>    possible.
> 
>  - I use still dereference in dump callback, so I think what I didn't
>    got was what happened when rcu_assign_pointer will do when rcu read
>    lock is held. I suppose the pointer will be updated, then we don't
>    have any issue here.

Series applied.
