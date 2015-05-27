From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] test_bpf: add similarly conflicting jump
 test case only for classic
Date: Wed, 27 May 2015 14:16:18 -0400 (EDT)
Message-ID: <20150527.141618.1170561992772984049.davem@davemloft.net>
References: <81f8411227ef0e1829b2b9511094112c3f4f3ca5.1432671849.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbbE0SQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:16:21 -0400
In-Reply-To: <81f8411227ef0e1829b2b9511094112c3f4f3ca5.1432671849.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 26 May 2015 22:35:43 +0200

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

Applied, thanks Daniel.
