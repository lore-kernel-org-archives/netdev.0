From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/2] bpf: reuse tc bpf prologue for sk skb progs
Date: Thu, 17 Aug 2017 09:12:07 -0700
Message-ID: <e1fca9db-10ea-fd64-9b5e-081a3c6eeca8@fb.com>
References: <cover.1502983087.git.daniel@iogearbox.net>
 <efce6714acbd646c1e83876504ae7c5fb5e12625.1502983087.git.daniel@iogearbox.net>
 <5995BEB1.8020509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33628 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751575AbdHQQMV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:12:21 -0400
In-Reply-To: <5995BEB1.8020509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/17 9:05 AM, John Fastabend wrote:
> On 08/17/2017 08:22 AM, Daniel Borkmann wrote:
>> Given both program types are effecitvely doing the same in the
>> prologue, just reuse the one that we had for tc and only adapt
>> to the corresponding drop verdict value. That way, we don't need
>> to have the duplicate from 8a31db561566 ("bpf: add access to sock
>> fields and pkt data from sk_skb programs") to maintain.
>>
>> Reported-by: Alexei Starovoitov <ast@kernel.org>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>  net/core/filter.c | 47 ++++++++++-------------------------------------
>>  1 file changed, 10 insertions(+), 37 deletions(-)
>>
>
> Nice clean-up, Thanks.
>
> Acked-by: John Fastabend <john.fastabend@gmail.com>
>

Acked-by: Alexei Starovoitov <ast@kernel.org>
