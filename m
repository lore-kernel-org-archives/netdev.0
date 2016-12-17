From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, test_verifier: fix a test case error result
 on unprivileged
Date: Sat, 17 Dec 2016 10:52:03 -0500 (EST)
Message-ID: <20161217.105203.2035176019970376891.davem@davemloft.net>
References: <639d61f73c907b704001ed2b115208998990eb38.1481762158.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932105AbcLQPwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:52:04 -0500
In-Reply-To: <639d61f73c907b704001ed2b115208998990eb38.1481762158.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 15 Dec 2016 01:39:10 +0100

> Running ./test_verifier as unprivileged lets 1 out of 98 tests fail:
> 
>   [...]
>   #71 unpriv: check that printk is disallowed FAIL
>   Unexpected error message!
>   0: (7a) *(u64 *)(r10 -8) = 0
>   1: (bf) r1 = r10
>   2: (07) r1 += -8
>   3: (b7) r2 = 8
>   4: (bf) r3 = r1
>   5: (85) call bpf_trace_printk#6
>   unknown func bpf_trace_printk#6
>   [...]
> 
> The test case is correct, just that the error outcome changed with
> ebb676daa1a3 ("bpf: Print function name in addition to function id").
> Same as with e00c7b216f34 ("bpf: fix multiple issues in selftest suite
> and samples") issue 2), so just fix up the function name.
> 
> Fixes: ebb676daa1a3 ("bpf: Print function name in addition to function id")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
