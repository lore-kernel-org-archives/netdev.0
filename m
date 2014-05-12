From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] BPF testsuite and cleanup
Date: Mon, 12 May 2014 00:25:47 -0400 (EDT)
Message-ID: <20140512.002547.1104211599437826768.davem@davemloft.net>
References: <1399583453-4315-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, edumazet@google.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaELEZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 00:25:48 -0400
In-Reply-To: <1399583453-4315-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  8 May 2014 14:10:50 -0700

> This patchset adds BPF testsuite and improves readability of classic
> to internal BPF converter.
> 
> The testsuite helped to find 'negative offset bug' in x64 JIT that was
> fixed by commit fdfaf64e ("x86: bpf_jit: support negative offsets")
> 
> It can be very useful for classic and internal JIT compiler developers.
> Also it serves as performance benchmark.
> 
> x86_64/i386 pass all tests with and without JIT. arm32 JIT is failing
> negative offset tests which are unsupported.
> 
> Internal BPF tests are much larger than classic tests to cover different
> combinations of registers. Negative tests check correctness of classic
> BPF verifier which must reject them.

Series applied, thanks.
