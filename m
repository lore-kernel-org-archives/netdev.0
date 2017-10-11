From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] Revert "net: defer call to cgroup_sk_alloc()"
Date: Tue, 10 Oct 2017 20:24:39 -0700 (PDT)
Message-ID: <20171010.202439.1828020457274885837.davem@davemloft.net>
References: <20171011021233.24158-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, hannes@cmpxchg.org,
        cgallek@google.com, tj@kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756607AbdJKDYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 23:24:40 -0400
In-Reply-To: <20171011021233.24158-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 10 Oct 2017 19:12:32 -0700

> This reverts commit fbb1fb4ad415cb31ce944f65a5ca700aaf73a227.
> 
> This was not the proper fix, lets cleanly revert it, so that
> following patch can be carried to stable versions.
> 
> sock_cgroup_ptr() callers do not expect a NULL return value.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
