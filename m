From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [V3 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Thu, 24 Aug 2017 07:46:13 -0700
Message-ID: <599EE6B5.7000605@gmail.com>
References: <20170823.170737.931093928208799430.davem@davemloft.net> <150357074701.26663.4047992776649697788.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36275 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdHXOqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:46:25 -0400
Received: by mail-pg0-f42.google.com with SMTP id r186so4735623pgr.3
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 07:46:25 -0700 (PDT)
In-Reply-To: <150357074701.26663.4047992776649697788.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2017 03:32 AM, Jesper Dangaard Brouer wrote:
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
> 
> ---

Series looks good to me. Thanks a lot.
