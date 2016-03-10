From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: bpf_stackmap_copy depends on
 CONFIG_PERF_EVENTS
Date: Wed, 09 Mar 2016 23:28:03 -0500 (EST)
Message-ID: <20160309.232803.2152242260458545384.davem@davemloft.net>
References: <1457578609-277357-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906AbcCJE2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 23:28:06 -0500
In-Reply-To: <1457578609-277357-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 9 Mar 2016 18:56:49 -0800

> 0-day bot reported build error:
> kernel/built-in.o: In function `map_lookup_elem':
>>> kernel/bpf/.tmp_syscall.o:(.text+0x329b3c): undefined reference to `bpf_stackmap_copy'
> when CONFIG_BPF_SYSCALL is set and CONFIG_PERF_EVENTS is not.
> Add weak definition to resolve it.
> This code path in map_lookup_elem() is never taken
> when CONFIG_PERF_EVENTS is not set.
> 
> Fixes: 557c0c6e7df8 ("bpf: convert stackmap to pre-allocation")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
