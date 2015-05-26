From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] test_bpf: add similarly conflicting jump
 test case only for classic
Date: Tue, 26 May 2015 13:43:26 -0700
Message-ID: <5564DAEE.9060108@plumgrid.com>
References: <81f8411227ef0e1829b2b9511094112c3f4f3ca5.1432671849.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32778 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbEZUn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 16:43:26 -0400
Received: by padbw4 with SMTP id bw4so101131562pad.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 13:43:26 -0700 (PDT)
In-Reply-To: <81f8411227ef0e1829b2b9511094112c3f4f3ca5.1432671849.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/15 1:35 PM, Daniel Borkmann wrote:
> While 3b52960266a3 ("test_bpf: add more eBPF jump torture cases")
> added the int3 bug test case only for eBPF, which needs exactly 11
> passes to converge, here's a version for classic BPF with 11 passes,
> and one that would need 70 passes on x86_64 to actually converge for
> being successfully JITed. Effectively, all jumps are being optimized
> out resulting in a JIT image of just 89 bytes (from originally max
> BPF insns), only returning K.
>
> Might be useful as a receipe for folks wanting to craft a test case
> when backporting the fix in commit 3f7352bf21f8 ("x86: bpf_jit: fix
> compilation of large bpf programs") while not having eBPF. The 2nd
> one is delegated to the interpreter as the last pass still results
> in shrinking, in other words, this one won't be JITed on x86_64.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

great tests. Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
