From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Apr 2017 08:30:17 -0400
Message-ID: <09120c61-cbdc-f048-d7bb-268e5af3e92d@mojatatu.com>
References: <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
 <8f1a1b14-ad9b-7840-1fa6-04f2a2e4f55d@mojatatu.com>
 <20170426120851.GE1867@nanopsycho.orion>
 <10fe2c22-8e76-543e-dd24-ddce5813ab69@mojatatu.com>
 <20170426135627.GI1867@nanopsycho.orion>
 <b32fb2fb-ffb1-aee8-5f1d-1f1e3c82b347@mojatatu.com>
 <20170427063039.GB1870@nanopsycho.orion>
 <c1680135-8c9f-14d0-c65e-7a5bb7d8d661@mojatatu.com>
 <20170428070207.GC1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35867 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965202AbdD1MaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:30:20 -0400
Received: by mail-it0-f66.google.com with SMTP id x188so5414987itb.3
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:30:19 -0700 (PDT)
In-Reply-To: <20170428070207.GC1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-28 03:02 AM, Jiri Pirko wrote:
> Fri, Apr 28, 2017 at 03:22:53AM CEST, jhs@mojatatu.com wrote:

[..]
>> Maybe I am misunderstanding:
>> Recall, this is what it looks like with this patchset:
>> <nlh><subsytem-header>[TCA_ROOT_XXXX]
>>
>> TCA_ROOT_XXX is very subsystem specific. classifiers, qdiscs and many
>> subsystems defined their own semantics for that TLV level. This specific
>> "dump max" is very very specific to actions. They were crippled by the
>> fact you could only send 32 at a time - this allows more to be sent.
>>
>> I thought initially you meant:
>> <nlh>[NLA_XXX]<subsytem-header>[TCA_ROOT_XXXX]
>>
>> I think at the NLA_XXX you could fit netlink wide TLVs - but if i said
>> "do a large dump" it is of no use to any other subsystem.
>
> Okay, I'm sorry, I had couple of beers yesterday so that might be
> the cause why your msg makes me totally confused :O
>
> All I suggest is to replace NLA_U32 flags you want that does not
> have any semantics with NLA_FLAGS flags, which eventually will carry
> the exact same u32, but with predefined semantics, helpers, everything.
>

I didnt understand fully Jiri. Are you suggesting a new type called
NLA_FLAGS which is re-usable elsewhere?

cheers,
jamal
