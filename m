From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 10:06:50 -0400
Message-ID: <49cf7772-2fd2-3ebb-bae4-a8b7ba4a3d60@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <20160927.015606.437705429903770747.davem@davemloft.net>
 <20160927110711.12555f4e@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32834 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932454AbcI0OHG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:07:06 -0400
Received: by mail-io0-f196.google.com with SMTP id r145so968403ior.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 07:06:52 -0700 (PDT)
In-Reply-To: <20160927110711.12555f4e@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-27 04:07 AM, Shmulik Ladkani wrote:
> Hi David,
>
> On Tue, 27 Sep 2016 01:56:06 -0400 (EDT), davem@davemloft.net wrote:
>> The discussion on this patch has ventured off into what to do about
>> recursion.
>>
>> But it unclear to me where this specific patch, and this series,
>> stands right now.  Someone please clear this up for me.
>
> Status:
>  - Series adds "ingress redirect/mirror" support
>  - Positive feedback for the feature
>  - So far no comments regarding code itself
>  - Questions raised regarding "recursion handling"
 >
>    Expressed that existing mirred code (i.e egress redirect) is *already*
>    loop-unsafe (and also, some non-tc netdev constructs, as exampled by
>    others).
>    Discussion then wandered to "recursion handling".

not totaly bike-shed discussion; legit issues are being raised
(and the egress issue you point out is fixable now that we are paying
attention to it).
We need to take care of loops. I pointed to how the original thought
process was. I _dont_ see this as resolvable via recursion handling
since this is per-skb and not per entry point.
You can add my Acked-by if you promise to take care of this issue next.

cheers,
jamal

PS:- the code looks straight forward
