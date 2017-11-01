From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH] bpf: cpumap micro-optimization in
 cpu_map_enqueue
Date: Wed, 1 Nov 2017 09:12:11 -0700
Message-ID: <20171101161210.55ekkcrkrsgltvx6@ast-mbp>
References: <150953668583.30172.5069550217700139382.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56650 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754593AbdKAQMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:12:12 -0400
Received: by mail-pg0-f68.google.com with SMTP id m18so2476979pgd.13
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:12:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150953668583.30172.5069550217700139382.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 12:44:45PM +0100, Jesper Dangaard Brouer wrote:
> Discovered that the compiler laid-out asm code in suboptimal way
> when studying perf report during benchmarking of cpumap. Help
> the compiler by the marking unlikely code paths.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
