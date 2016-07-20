From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4
 anon union initialization bug
Date: Tue, 19 Jul 2016 19:28:01 -0700 (PDT)
Message-ID: <20160719.192801.35741043299529276.davem@davemloft.net>
References: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbcGTC2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 22:28:02 -0400
In-Reply-To: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 18 Jul 2016 15:50:58 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon union initialization bug
> 
> kernel/trace/bpf_trace.c: In function 'bpf_event_output':
> kernel/trace/bpf_trace.c:312: error: unknown field 'next' specified in initializer
> kernel/trace/bpf_trace.c:312: warning: missing braces around initializer
> kernel/trace/bpf_trace.c:312: warning: (near initialization for 'raw.frag.<anonymous>')
> 
> Fixes: 555c8a8623a3a87 ("bpf: avoid stack copy and use skb ctx for event output")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
