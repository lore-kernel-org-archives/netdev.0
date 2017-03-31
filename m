From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN command
Date: Fri, 31 Mar 2017 11:37:16 +0800
Message-ID: <d9bc0627-c409-a6b6-b50c-aa84cb9f3186@huawei.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-2-ast@fb.com>
 <9105ab34-8fee-fab4-96fe-3bfe7f3a84b7@huawei.com>
 <d8c30545-b247-6831-41cc-a546404d6b0a@fb.com>
 <67b19080-26f9-67ac-d7fa-e621a90c54bb@huawei.com>
 <35b22fbd-546b-779b-9dc0-1f9a914e33cf@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4868 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S932700AbdCaDos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 23:44:48 -0400
In-Reply-To: <35b22fbd-546b-779b-9dc0-1f9a914e33cf@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/31 11:24, Alexei Starovoitov wrote:
> On 3/30/17 8:12 PM, Wangnan (F) wrote:
>>
>>
>> On 2017/3/31 10:57, Alexei Starovoitov wrote:
>>> On 3/30/17 7:53 PM, Wangnan (F) wrote:
>>>> I suggest using a CONFIG option to enable/disable code in
>>>> test_run.o to reduce attack plane.
>>>
>>> attack plane? what attack do you see and how config helps?
>>>
>>
>> I think all testing features are not required to be compiled
>> for a production system. A feature which should never be used
>> looks dangerous to me.
>
> It is required on production system, since xdp testing and
> xdp production has to use the same kernel. We cannot
> keep rebooting the server back and forth to test and then to run.
> It's not testing the kernel features, it's testing bpf programs
> which are technically user space components.
>

Okay. Now I understand it is a production feature.

Thank you.
