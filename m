From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net-next] net: set SK_MEM_QUANTUM to 4096
Date: Mon, 31 Oct 2016 21:00:12 -0400 (EDT)
Message-ID: <20161031.210012.157436292631351243.davem@redhat.com>
References: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
        <1477945975.7065.317.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56124 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S948411AbcKABAO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 21:00:14 -0400
In-Reply-To: <1477945975.7065.317.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Oct 2016 13:32:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Systems with large pages (64KB pages for example) do not always have
> huge quantity of memory.
> 
> A big SK_MEM_QUANTUM value leads to fewer interactions with the
> global counters (like tcp_memory_allocated) but might trigger
> memory pressure much faster, giving suboptimal TCP performance
> since windows are lowered to ridiculous values.
> 
> Note that sysctl_mem units being in pages and in ABI, we also need
> to change sk_prot_mem_limits() accordingly.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
