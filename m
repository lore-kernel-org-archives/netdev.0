From: David Miller <davem@davemloft.net>
Subject: Re: [V3 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Thu, 24 Aug 2017 12:00:17 -0700 (PDT)
Message-ID: <20170824.120017.1701190804482902696.davem@davemloft.net>
References: <20170823.170737.931093928208799430.davem@davemloft.net>
        <150357074701.26663.4047992776649697788.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752974AbdHXTAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:00:18 -0400
In-Reply-To: <150357074701.26663.4047992776649697788.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 24 Aug 2017 12:32:58 +0200

> More work on streamlining and performance optimizing the tracepoints
> for XDP.
> 
> I've created a simple xdp_monitor application that uses this
> tracepoint, and prints statistics. Available at github:
> 
> https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_kern.c
> https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_user.c
> 
> The improvement over tracepoint with strcpy: 9810372 - 8428762 = +1381610 pps faster
>  - (1/9810372 - 1/8428762)*10^9 = -16.7 nanosec
>  - 100-(8428762/9810372*100) = strcpy-trace is 14.08% slower
>  - 981037/8428762*100 = removing strcpy made it 11.64% faster
> 
> V3: Fix merge conflict with commit e4a8e817d3cb ("bpf: misc xdp redirect cleanups")
> V2: Change trace_xdp_redirect() to align with args of trace_xdp_exception()

Series applied, thanks Jesper.
