From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 4/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Fri, 31 Mar 2017 10:48:11 +0800
Message-ID: <97e058b2-08e6-c99e-48ae-09a836696ad8@huawei.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-5-ast@fb.com>
 <b4ebf55a-d509-f4b8-8d71-c5dfc31f9c9d@huawei.com>
 <1e3156bf-7334-53fe-1069-7d7bd9dc09fb@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4864 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750968AbdCaCtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:49:08 -0400
In-Reply-To: <1e3156bf-7334-53fe-1069-7d7bd9dc09fb@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/31 10:37, Alexei Starovoitov wrote:
> On 3/30/17 7:33 PM, Wangnan (F) wrote:
>>> +void bpf_program__set_type(struct bpf_program *prog, enum
>>> bpf_prog_type type);
>>>
>>
>> This makes libbpf.h depend on uapi/linux/bpf.h (because of enum
>> bpf_prog_type), which is not always available.
>>
>> What about defining another enum inside libbpf.h?
>
> how about just including bpf.h? or making it 'int' instead of enum?
>

Including either kernel header into libbpf.h makes a lot of trouble,
because kernel header and uapi have many other things we don't need
and may conflict with existing code.

Making it 'int' looks like a backdoor. We still need macro to define
each program type.

Thank you.
