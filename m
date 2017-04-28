From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Apr 2017 16:02:08 +0200
Message-ID: <20170428140208.GG1886@nanopsycho.orion>
References: <20170426120851.GE1867@nanopsycho.orion>
 <10fe2c22-8e76-543e-dd24-ddce5813ab69@mojatatu.com>
 <20170426135627.GI1867@nanopsycho.orion>
 <b32fb2fb-ffb1-aee8-5f1d-1f1e3c82b347@mojatatu.com>
 <20170427063039.GB1870@nanopsycho.orion>
 <c1680135-8c9f-14d0-c65e-7a5bb7d8d661@mojatatu.com>
 <20170428070207.GC1886@nanopsycho.orion>
 <09120c61-cbdc-f048-d7bb-268e5af3e92d@mojatatu.com>
 <20170428132115.GD1886@nanopsycho.orion>
 <5377f9a5-56db-537d-1079-ead60b67c71e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36355 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426128AbdD1OCL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 10:02:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so11101455wmu.3
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 07:02:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5377f9a5-56db-537d-1079-ead60b67c71e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 03:42:31PM CEST, jhs@mojatatu.com wrote:
>On 17-04-28 09:21 AM, Jiri Pirko wrote:
>> Fri, Apr 28, 2017 at 02:30:17PM CEST, jhs@mojatatu.com wrote:
>> > On 17-04-28 03:02 AM, Jiri Pirko wrote:
>> > > Fri, Apr 28, 2017 at 03:22:53AM CEST, jhs@mojatatu.com wrote:
>> > 
>> > [..]
>> > > > Maybe I am misunderstanding:
>> > > > Recall, this is what it looks like with this patchset:
>> > > > <nlh><subsytem-header>[TCA_ROOT_XXXX]
>> > > > 
>> > > > TCA_ROOT_XXX is very subsystem specific. classifiers, qdiscs and many
>> > > > subsystems defined their own semantics for that TLV level. This specific
>> > > > "dump max" is very very specific to actions. They were crippled by the
>> > > > fact you could only send 32 at a time - this allows more to be sent.
>
>> > > 
>> > > All I suggest is to replace NLA_U32 flags you want that does not
>> > > have any semantics with NLA_FLAGS flags, which eventually will carry
>> > > the exact same u32, but with predefined semantics, helpers, everything.
>> > > 
>> > 
>> > I didnt understand fully Jiri. Are you suggesting a new type called
>> > NLA_FLAGS which is re-usable elsewhere?
>> 
>> Exactly. That's what I'm saying.
>> 
>
>If you want to make it general:
>I see the semantics of this thing as more detailed than what I had.
>It would have a u32 bitmap + u32 bitmask.

Sure, lets make this nice.
