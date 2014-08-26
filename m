From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: x86: add missing 'shift by register'
 instructions to x64 eBPF JIT
Date: Mon, 25 Aug 2014 17:34:18 -0700 (PDT)
Message-ID: <20140825.173418.1069939395052253481.davem@davemloft.net>
References: <1408994822-14929-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, hpa@zytor.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:34:19 -0400
In-Reply-To: <1408994822-14929-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 25 Aug 2014 12:27:02 -0700

> 'shift by register' operations are supported by eBPF interpreter, but were
> accidently left out of x64 JIT compiler. Fix it and add a testcase.
> 
> Reported-by: Brendan Gregg <brendan.d.gregg@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> ---
> 
> Probably not worth sending to stable, but wouldn't hurt either.

Applied to net-next, thanks.
