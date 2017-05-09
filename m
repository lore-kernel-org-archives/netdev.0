From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: bpf: add ppc64 and sparc64 to list of
 archs with eBPF support
Date: Mon, 8 May 2017 23:06:19 -0700
Message-ID: <20170508230619.2d339edd@xeon-e3>
References: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36282 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752393AbdEIGG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 02:06:27 -0400
Received: by mail-pg0-f41.google.com with SMTP id 64so22934449pgb.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 23:06:26 -0700 (PDT)
In-Reply-To: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  6 May 2017 22:30:10 +0200
Alexander Alemayhu <alexander@alemayhu.com> wrote:

> sparc64 support was added in 7a12b5031c6b (sparc64: Add eBPF JIT., 2017-04-17)[0]
> and ppc64 in 156d0e290e96 (powerpc/ebpf/jit: Implement JIT compiler for extended BPF, 2016-06-22)[1].
> 
> [0]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=7a12b5031c6b
> [1]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=156d0e290e96
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
> ---
>  man/man8/tc-bpf.8 | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
> index e371964d06ab..2e9812ede028 100644
> --- a/man/man8/tc-bpf.8
> +++ b/man/man8/tc-bpf.8
> @@ -75,9 +75,9 @@ In Linux, it's generally considered that eBPF is the successor of cBPF.
>  The kernel internally transforms cBPF expressions into eBPF expressions and
>  executes the latter. Execution of them can be performed in an interpreter
>  or at setup time, they can be just-in-time compiled (JIT'ed) to run as
> -native machine code. Currently, x86_64, ARM64 and s390 architectures have
> -eBPF JIT support, whereas PPC, SPARC, ARM and MIPS have cBPF, but did not
> -(yet) switch to eBPF JIT support.
> +native machine code. Currently, x86_64, ARM64, s390, ppc64 and sparc64
> +architectures have eBPF JIT support, whereas PPC, SPARC, ARM and MIPS have
> +cBPF, but did not (yet) switch to eBPF JIT support.
>  
>  eBPF's instruction set has similar underlying principles as the cBPF
>  instruction set, it however is modelled closer to the underlying

Applied thanks.
