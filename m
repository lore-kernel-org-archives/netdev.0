From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [2/3] powerpc: bpf: flush the entire JIT buffer
Date: Fri, 27 Jan 2017 11:40:33 +1100 (AEDT)
Message-ID: <3v8g1Y720jz9t25@ozlabs.org>
References: <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:46415 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752130AbdA0AlM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 19:41:12 -0500
In-Reply-To: <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 17:10:01 UTC, "Naveen N. Rao" wrote:
> With bpf_jit_binary_alloc(), we allocate at a page granularity and fill
> the rest of the space with illegal instructions to mitigate BPF spraying
> attacks, while having the actual JIT'ed BPF program at a random location
> within the allocated space. Under this scenario, it would be better to
> flush the entire allocated buffer rather than just the part containing
> the actual program. We already flush the buffer from start to the end of
> the BPF program. Extend this to include the illegal instructions after
> the BPF program.
> 
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/10528b9c45cfb9e8f45217ef2f5ef8

cheers
