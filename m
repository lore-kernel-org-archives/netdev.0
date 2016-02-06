From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bpf: introduce per-cpu maps
Date: Sat, 06 Feb 2016 03:35:10 -0500 (EST)
Message-ID: <20160206.033510.1628943759911841700.davem@davemloft.net>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, tom.leiming@gmail.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFIfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:35:15 -0500
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 1 Feb 2016 22:39:52 -0800

> We've started to use bpf to trace every packet and atomic add
> instruction (event JITed) started to show up in perf profile.
> The solution is to do per-cpu counters.
> For PERCPU_(HASH|ARRAY) map the existing bpf_map_lookup() helper
> returns per-cpu area which bpf programs can use to store and
> increment the counters. The BPF_MAP_LOOKUP_ELEM syscall command
> returns areas from all cpus and user process aggregates the counters.
> The usage example is in patch 6. The api turned out to be very
> easy to use from bpf program and from user space.
> Long term we were discussing to add 'bounded loop' instruction,
> so bpf programs can do aggregation within the program which may
> help some use cases. Right now user space aggregation of
> per-cpu counters fits the best.
> 
> This patch set is new approach for per-cpu hash and array maps.
> I've reused the map tests written by Martin and Ming, but
> implementation and api is new. Old discussion here:
> http://thread.gmane.org/gmane.linux.kernel/2123800/focus=2126435

Series applied, thanks Alexei.
