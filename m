From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] samples/bpf: fix warnings in xdp_monitor_user
Date: Sun, 1 Oct 2017 18:35:57 -0700
Message-ID: <20171002013556.tfz4o5tbxqpbvchb@ast-mbp>
References: <20171001210734.27010-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34041 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbdJBBgA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 21:36:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id g65so4125215pfe.1
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 18:36:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171001210734.27010-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 01, 2017 at 02:07:34PM -0700, Stephen Hemminger wrote:
> Make local functions static to fix
> 
>   HOSTCC  samples/bpf/xdp_monitor_user.o
> samples/bpf/xdp_monitor_user.c:64:7: warning: no previous prototype for ‘gettime’ [-Wmissing-prototypes]
>  __u64 gettime(void)
>        ^~~~~~~
> samples/bpf/xdp_monitor_user.c:209:6: warning: no previous prototype for ‘print_bpf_prog_info’ [-Wmissing-prototypes]
>  void print_bpf_prog_info(void)
>       ^~~~~~~~~~~~~~~~~~~
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Fixes: 3ffab5460264 ("samples/bpf: xdp_monitor tool based on tracepoints")
Acked-by: Alexei Starovoitov <ast@kernel.org>
