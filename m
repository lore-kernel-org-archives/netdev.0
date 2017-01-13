From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/3] powerpc: bpf: flush the entire JIT buffer
Date: Fri, 13 Jan 2017 12:10:56 -0800
Message-ID: <20170113201055.GB60330@ast-mbp.thefacebook.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        davem@davemloft.net
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34630 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdAMULC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 15:11:02 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so9683149pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:11:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 10:40:01PM +0530, Naveen N. Rao wrote:
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

Acked-by: Alexei Starovoitov <ast@kernel.org>
