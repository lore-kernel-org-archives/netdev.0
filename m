From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 4/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Thu, 30 Mar 2017 19:37:41 -0700
Message-ID: <1e3156bf-7334-53fe-1069-7d7bd9dc09fb@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-5-ast@fb.com>
 <b4ebf55a-d509-f4b8-8d71-c5dfc31f9c9d@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58337 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750820AbdCaCiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:38:20 -0400
In-Reply-To: <b4ebf55a-d509-f4b8-8d71-c5dfc31f9c9d@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 7:33 PM, Wangnan (F) wrote:
>> +void bpf_program__set_type(struct bpf_program *prog, enum
>> bpf_prog_type type);
>>
>
> This makes libbpf.h depend on uapi/linux/bpf.h (because of enum
> bpf_prog_type), which is not always available.
>
> What about defining another enum inside libbpf.h?

how about just including bpf.h? or making it 'int' instead of enum?
