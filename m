From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf/verifier: reject invalid LD_ABS | BPF_DW
 instruction
Date: Thu, 14 Apr 2016 01:32:35 -0400 (EDT)
Message-ID: <20160414.013235.548560317273289663.davem@davemloft.net>
References: <1460481979-1771165-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbcDNFch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 01:32:37 -0400
In-Reply-To: <1460481979-1771165-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 12 Apr 2016 10:26:19 -0700

> verifier must check for reserved size bits in instruction opcode and
> reject BPF_LD | BPF_ABS | BPF_DW and BPF_LD | BPF_IND | BPF_DW instructions,
> otherwise interpreter will WARN_RATELIMIT on them during execution.
> 
> Fixes: ddd872bc3098 ("bpf: verifier: add checks for BPF_ABS | BPF_IND instructions")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks.
