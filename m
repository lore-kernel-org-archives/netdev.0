From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] x86: bpf_jit: fix FROM_BE16 and FROM_LE16/32
 instructions
Date: Tue, 12 May 2015 23:14:09 -0400 (EDT)
Message-ID: <20150512.231409.160408009979608790.davem@davemloft.net>
References: <1431411916-6104-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933909AbbEMDOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:14:11 -0400
In-Reply-To: <1431411916-6104-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 11 May 2015 23:25:16 -0700

> FROM_BE16:
> 'ror %reg, 8' doesn't clear upper bits of the register,
> so use additional 'movzwl' insn to zero extend 16 bits into 64
> 
> FROM_LE16:
> should zero extend lower 16 bits into 64 bit
> 
> FROM_LE32:
> should zero extend lower 32 bits into 64 bit
> 
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thank you.
