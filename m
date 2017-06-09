From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in
 ip6_output
Date: Fri, 9 Jun 2017 16:12:18 -0700
Message-ID: <3e187bb4-df36-1791-aa92-03a348b68b14@gmail.com>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
 <20170609.150836.1427149901008136163.davem@davemloft.net>
 <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com>
 <20170609.153937.1403217696199851743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, edumazet@google.com,
        fengc@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33087 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdFIXMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 19:12:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so9937940pfe.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 16:12:19 -0700 (PDT)
In-Reply-To: <20170609.153937.1403217696199851743.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/09/2017 12:39 PM, David Miller wrote:
> From: Chenbo Feng <chenbofeng.kernel@gmail.com>
> Date: Fri, 9 Jun 2017 12:13:57 -0700
>
>>
>> On 06/09/2017 12:08 PM, David Miller wrote:
>>> From: Chenbo Feng <chenbofeng.kernel@gmail.com>
>>> Date: Fri,  9 Jun 2017 12:06:07 -0700
>>>
>>>> From: Chenbo Feng <fengc@google.com>
>>>>
>>>> Move the initialization of skb->dev and skb->protocol from
>>>> ip6_finish_output2 to ip6_output. This can make the skb->dev and
>>>> skb->protocol information avalaible to the CGROUP eBPF filter.
>>>>
>>>> Signed-off-by: Chenbo Feng <fengc@google.com>
>>>> Acked-by: Eric Dumazet <edumazet@google.com>
>>> Applied, thanks.
>>>
>>> This makes ipv6 consistent with ipv4.
>>>
>>> I am surprised this wasn't noticed, for example, in netfilter.
>>> .
>>>
>> Hi David,
>>
>> This patch is still under working since it may have problem with
>> ip_fragment() call, did you applied it already? Should I send a revert
>> patch to you then?
> A revert is necessary or a relative fixup.
>
> Thank you.
>
Hi David,

The revert is uploaded here: http://patchwork.ozlabs.org/patch/774136/

Thanks and sorry for the trouble caused

Chenbo Feng
