From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net] rps: flow_dissector: Fix uninitialized flow_keys used
 in __skb_get_hash possibly
Date: Wed, 31 Aug 2016 14:28:35 +0800
Message-ID: <CA+6hz4qgR21ZPvk7-N=t6=BkH1TpCdLcGvJ5njQXGWqooHJ_Tg@mail.gmail.com>
References: <1472612179-23601-1-git-send-email-fgao@ikuai8.com>
 <1472616890.14381.298.camel@edumazet-glaptop3.roam.corp.google.com> <CA+6hz4rzMpNFOtr9m0pox1ejMBF5cQXgb9eGoR8q8sDeLTMvqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Tom Herbert <tom@herbertland.com>,
        Alex Duyck <aduyck@mirantis.com>, amir@vadai.me,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:43893 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752256AbcHaG25 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 02:28:57 -0400
In-Reply-To: <CA+6hz4rzMpNFOtr9m0pox1ejMBF5cQXgb9eGoR8q8sDeLTMvqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 12:16 PM, Gao Feng <fgao@ikuai8.com> wrote:
> On Wed, Aug 31, 2016 at 12:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2016-08-31 at 10:56 +0800, fgao@ikuai8.com wrote:
>>> From: Gao Feng <fgao@ikuai8.com>
>>>
>>> The original codes depend on that the function parameters are evaluated from
>>> left to right. But the parameter's evaluation order is not defined in C
>>> standard actually.
>>>
>>> When flow_keys_have_l4(&keys) is invoked before ___skb_get_hash(skb, &keys,
>>> hashrnd) with some compilers or environment, the keys passed to
>>> flow_keys_have_l4 is not initialized.
>>>
>>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>> ---
>>
>> Good catch, please add
>>
>> Fixes: 6db61d79c1e1 ("flow_dissector: Ignore flow dissector return value from ___skb_get_hash")
>> Acked-by: Eric Dumazet <edumazet@google.com>
>>
>>
>
> Add it into the description and resend the patch again?
>
> Best Regards
> Feng

Hi Eric,

I have sent the update "v2" patch which has the description "Fixes:
6db61d79c1e1 ("flow_dissector: Ignore flow dissector return value from
___skb_get_hash")".
Could you help review it again please?

Best Regards
Feng
