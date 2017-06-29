From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: prevent leaking pointer via xadd on
 unpriviledged
Date: Wed, 28 Jun 2017 20:41:04 -0700
Message-ID: <79a17a55-66d6-3a2f-18da-bbd1b3489a66@fb.com>
References: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kafai@fb.com>, <john.fastabend@gmail.com>,
        <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54162 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751541AbdF2DnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 23:43:03 -0400
In-Reply-To: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/17 6:04 PM, Daniel Borkmann wrote:
> Prevent this by checking xadd src reg for pointer types. Also
> add a couple of test cases related to this.
>
> Fixes: 1be7f75d1668 ("bpf: enable non-root eBPF programs")
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
