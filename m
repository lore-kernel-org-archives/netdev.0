From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sat, 14 Jan 2017 07:56:35 -0500
Message-ID: <68e41fe4-5c4c-e159-fbfc-17d06638707d@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <20170108171902.GH1971@nanopsycho> <5873D523.4030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33863 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdANM4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 07:56:38 -0500
Received: by mail-io0-f196.google.com with SMTP id c80so8209159iod.1
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 04:56:38 -0800 (PST)
In-Reply-To: <5873D523.4030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-09 01:23 PM, John Fastabend wrote:
> On 17-01-08 09:19 AM, Jiri Pirko wrote:

[..]
>> This should never be interpreted by kernel. I think this would be good
>> to make clear in the comment in the code.
>>
>
> Ah OK I had assumed you would be pushing this via tc_cls_flower_offload into
> the driver in a follow up patch. But if it lives in kernel space as opaque
> cookie guess its no different then other id fields order/prio/cookie.
>
> Thanks for clarifying.


I think the feature makes a lot of sense (as is the action variant).
But can we make it:
a) fixed size
b) apply to all classifiers
c) please post a usage example via iproute2/tc

I am going to post the action variant in the next while - will do some 
more testing first.

cheers,
jamal
