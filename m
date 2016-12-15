From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf, test_verifier: fix a test case error result on
 unprivileged
Date: Wed, 14 Dec 2016 16:43:50 -0800
Message-ID: <5851E746.9090604@fb.com>
References: <639d61f73c907b704001ed2b115208998990eb38.1481762158.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51809 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752925AbcLOApH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:45:07 -0500
In-Reply-To: <639d61f73c907b704001ed2b115208998990eb38.1481762158.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/16 4:39 PM, Daniel Borkmann wrote:
> Running ./test_verifier as unprivileged lets 1 out of 98 tests fail:
>
>    [...]
>    #71 unpriv: check that printk is disallowed FAIL
>    Unexpected error message!
>    0: (7a) *(u64 *)(r10 -8) = 0
>    1: (bf) r1 = r10
>    2: (07) r1 += -8
>    3: (b7) r2 = 8
>    4: (bf) r3 = r1
>    5: (85) call bpf_trace_printk#6
>    unknown func bpf_trace_printk#6
>    [...]
>
> The test case is correct, just that the error outcome changed with
> ebb676daa1a3 ("bpf: Print function name in addition to function id").
> Same as with e00c7b216f34 ("bpf: fix multiple issues in selftest suite
> and samples") issue 2), so just fix up the function name.
>
> Fixes: ebb676daa1a3 ("bpf: Print function name in addition to function id")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

was thinking to send the same fix. Thanks you for beating me :)
Acked-by: Alexei Starovoitov <ast@kernel.org>
