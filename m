From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: x86: bpf: don't forget to free sk_filter (v2)
Date: Thu, 07 Nov 2013 19:07:27 -0500 (EST)
Message-ID: <20131107.190727.1219440287544649912.davem@davemloft.net>
References: <1383798912-10832-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ast@plumgrid.com, edumazet@google.com
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab3KHAH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:07:29 -0500
In-Reply-To: <1383798912-10832-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>
Date: Thu,  7 Nov 2013 08:35:12 +0400

> sk_filter isn't freed if bpf_func is equal to sk_run_filter.
> 
> This memory leak was introduced by v3.12-rc3-224-gd45ed4a4
> "net: fix unsafe set_memory_rw from softirq".
> 
> Before this patch sk_filter was freed in sk_filter_release_rcu,
> now it should be freed in bpf_jit_free.
> 
> Here is output of kmemleak:
 ...
> v2: add extra { } after else
> 
> Fixes: d45ed4a4e33a ("net: fix unsafe set_memory_rw from softirq")
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks!
