From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Fri, 01 May 2015 08:15:55 -0400
Message-ID: <55436E7B.80800@mojatatu.com>
References: <5542CC25.8060501@mojatatu.com> <20150501094619.GA22481@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37681 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbEAMP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:15:57 -0400
Received: by igblo3 with SMTP id lo3so36194896igb.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 05:15:56 -0700 (PDT)
In-Reply-To: <20150501094619.GA22481@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 05/01/15 05:46, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 04/30/15 17:16, Alexei Starovoitov wrote:
>>> On Thu, Apr 30, 2015 at 12:12:00PM +0200, Florian Westphal wrote:
>>>> Not used.
>>>>
>>>> pedit sets TC_MUNGED when packet content was altered, but all the core
>>>> does is unset MUNGED again and then set OK2MUNGE.
>>>>
>>>> And the latter isn't tested anywhere. So lets remove both
>>>> TC_MUNGED and TC_OK2MUNGE.
>>>>
>>>> Signed-off-by: Florian Westphal <fw@strlen.de>
>>>
>>> Wanted to do the same.
>>> iproute2 doesn't use 'munge' flag either.
>>>
>>> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>>>
>>
>> Florian,
>> If you are going to take this path then fix pedit to do a pskb_expand.
>
> Jamal, what about this:
>
> - I'll wait for this patch to be accepted or rejected
> - same for your suggested rttl removal patch to go in
>

I am fine with what you suggest.
So here's my ack: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by:
Can you please CC me on the other patches so i can review?

cheers,
jamal
