From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: fix bpf_perf_event_output
 prototype
Date: Wed, 10 Aug 2016 23:13:00 -0700 (PDT)
Message-ID: <20160810.231300.570988327885018926.davem@davemloft.net>
References: <1470847539-2048114-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, arb@fb.com, netdev@vger.kernel.org,
	kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbcHKGNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 02:13:02 -0400
In-Reply-To: <1470847539-2048114-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 10 Aug 2016 09:45:39 -0700

> From: Adam Barth <arb@fb.com>
> 
> The commit 555c8a8623a3 ("bpf: avoid stack copy and use skb ctx for event output")
> started using 20 of initially reserved upper 32-bits of 'flags' argument
> in bpf_perf_event_output(). Adjust corresponding prototype in samples/bpf/bpf_helpers.h
> 
> Signed-off-by: Adam Barth <arb@fb.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
