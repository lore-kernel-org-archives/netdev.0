From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] powerpc: bpf: flush the entire JIT buffer
Date: Fri, 13 Jan 2017 23:55:00 +0100
Message-ID: <58795AC4.2070302@iogearbox.net>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com> <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ast@fb.com,
        davem@davemloft.net
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
        mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47808 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdAMWzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:55:10 -0500
In-Reply-To: <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 06:10 PM, Naveen N. Rao wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
