From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix verifier memory corruption
Date: Thu, 16 Apr 2015 12:07:00 -0400 (EDT)
Message-ID: <20150416.120700.1239591146749471799.davem@davemloft.net>
References: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbDPQHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:07:02 -0400
In-Reply-To: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 14 Apr 2015 15:57:13 -0700

> Due to missing bounds check the DAG pass of the BPF verifier can corrupt
> the memory which can cause random crashes during program loading:
> 
> [8.449451] BUG: unable to handle kernel paging request at ffffffffffffffff
> [8.451293] IP: [<ffffffff811de33d>] kmem_cache_alloc_trace+0x8d/0x2f0
> [8.452329] Oops: 0000 [#1] SMP
> [8.452329] Call Trace:
> [8.452329]  [<ffffffff8116cc82>] bpf_check+0x852/0x2000
> [8.452329]  [<ffffffff8116b7e4>] bpf_prog_load+0x1e4/0x310
> [8.452329]  [<ffffffff811b190f>] ? might_fault+0x5f/0xb0
> [8.452329]  [<ffffffff8116c206>] SyS_bpf+0x806/0xa30
> 
> Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thanks.
