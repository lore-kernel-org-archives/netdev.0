From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test_bpf: add more eBPF jump torture cases
Date: Fri, 22 May 2015 16:28:57 -0700
Message-ID: <555FBBB9.2070509@plumgrid.com>
References: <b23d3a10edbe46ac70bcc57a05ece597e1b6c09c.1432335952.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36254 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757335AbbEVX27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 19:28:59 -0400
Received: by igbpi8 with SMTP id pi8so1836716igb.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 16:28:59 -0700 (PDT)
In-Reply-To: <b23d3a10edbe46ac70bcc57a05ece597e1b6c09c.1432335952.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/22/15 4:10 PM, Daniel Borkmann wrote:
> Add two more eBPF test cases for JITs, i.e. the second one revealed a
> bug in the x86_64 JIT compiler, where only an int3 filled image from
> the allocator was emitted and later wrongly set by the compiler as the
> bpf_func program code since optimization pass boundary was surpassed
> w/o actually emitting opcodes.
>
> Interpreter:
>
>    [   45.782892] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:0 11 PASS
>    [   45.783062] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:0 14705 PASS
>
> After x86_64 JIT (fixed):
>
>    [   80.495638] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:1 6 PASS
>    [   80.495957] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:1 17157 PASS
>
> Reference: http://thread.gmane.org/gmane.linux.network/364729
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks a lot for great tests!

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
