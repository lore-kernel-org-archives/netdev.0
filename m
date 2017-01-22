From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 3/3] samples/bpf: add lpm-trie benchmark
Date: Sun, 22 Jan 2017 15:02:06 -0800
Message-ID: <20170122230205.GD73160@ast-mbp.thefacebook.com>
References: <20170121162613.4159-1-daniel@zonque.org>
 <20170121162613.4159-4-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34633 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAVXCL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 18:02:11 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so12007810pgt.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 15:02:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170121162613.4159-4-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 05:26:13PM +0100, Daniel Mack wrote:
> From: David Herrmann <dh.herrmann@gmail.com>
> 
> Extend the map_perf_test_{user,kern}.c infrastructure to stress test
> lpm-trie lookups. We hook into the kprobe on sys_gettid() and measure
> the latency depending on trie size and lookup count.
> 
> On my Intel Haswell i7-6400U, a single gettid() syscall with an empty
> bpf program takes roughly 6.5us on my system. Lookups in empty tries
> take ~1.8us on first try, ~0.9us on retries. Lookups in tries with 8192
> entries take ~7.1us (on the first _and_ any subsequent try).
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> Reviewed-by: Daniel Mack <daniel@zonque.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

Thank you for all the hard work you've put into these patches.
All looks great to me.
