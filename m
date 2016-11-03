From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] inet: fix sleeping inside inet_wait_for_connect()
Date: Thu, 03 Nov 2016 15:18:37 -0400 (EDT)
Message-ID: <20161103.151837.1665512827704149616.davem@davemloft.net>
References: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com,
        eric.dumazet@gmail.com, peterz@infradead.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbcKCTTJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:19:09 -0400
In-Reply-To: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  1 Nov 2016 16:04:36 -0700

> Andrey reported this kernel warning:
 ...
> Unlike commit 26cabd31259ba43f68026ce3f62b78094124333f
> ("sched, net: Clean up sk_wait_event() vs. might_sleep()"), the
> sleeping function is called before schedule_timeout(), this is indeed
> a bug. Fix this by moving the wait logic to the new API, it is similar
> to commit ff960a731788a7408b6f66ec4fd772ff18833211
> ("netdev, sched/wait: Fix sleeping inside wait event").
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
