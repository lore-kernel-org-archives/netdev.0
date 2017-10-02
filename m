From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] samples/bpf: fix warnings in xdp_monitor_user
Date: Mon, 2 Oct 2017 07:43:05 +0200
Message-ID: <20171002074305.73024910@redhat.com>
References: <20171001210734.27010-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com, ast@kernel.org, daniel@iogearbox.net,
        netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750752AbdJBFnL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 01:43:11 -0400
In-Reply-To: <20171001210734.27010-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  1 Oct 2017 14:07:34 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

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
> ---
>  samples/bpf/xdp_monitor_user.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
