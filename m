From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, arm64: fix jit branch offset related to
 ldimm64
Date: Tue, 02 May 2017 15:06:04 -0400 (EDT)
Message-ID: <20170502.150604.1278120708759571672.davem@davemloft.net>
References: <5f7d105a1830ed789f1b416dc17b02fce0bd070e.1493749880.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org, xi.wang@gmail.com,
        catalin.marinas@arm.com, zlim.lnx@gmail.com,
        linux-arm-kernel@lists.infradead.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEBTGG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:06:06 -0400
In-Reply-To: <5f7d105a1830ed789f1b416dc17b02fce0bd070e.1493749880.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  2 May 2017 20:34:54 +0200

> When the instruction right before the branch destination is
> a 64 bit load immediate, we currently calculate the wrong
> jump offset in the ctx->offset[] array as we only account
> one instruction slot for the 64 bit load immediate although
> it uses two BPF instructions. Fix it up by setting the offset
> into the right slot after we incremented the index.
 ...
> Also, add a couple of test cases to make sure JITs pass
> this test. Tested on Cavium ThunderX ARMv8. The added
> test cases all pass after the fix.
> 
> Fixes: 8eee539ddea0 ("arm64: bpf: fix out-of-bounds read in bpf2a64_offset()")
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks!

I also applied your XADD patch as well.

Thanks again.
