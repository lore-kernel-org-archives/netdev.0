From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: call cgroup_sk_alloc() earlier in
 sk_clone_lock()
Date: Tue, 10 Oct 2017 20:24:47 -0700 (PDT)
Message-ID: <20171010.202447.2197911623378045472.davem@davemloft.net>
References: <20171011021233.24158-1-edumazet@google.com>
        <20171011021233.24158-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, hannes@cmpxchg.org,
        cgallek@google.com, tj@kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756607AbdJKDYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 23:24:48 -0400
In-Reply-To: <20171011021233.24158-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 10 Oct 2017 19:12:33 -0700

> If for some reason, the newly allocated child need to be freed,
> we will call cgroup_put() (via sk_free_unlock_clone()) while the
> corresponding cgroup_get() was not yet done, and we will free memory
> too soon.
> 
> Fixes: d979a39d7242 ("cgroup: duplicate cgroup reference when cloning sockets")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
