From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 9 Jan 2017 10:23:31 -0800
Message-ID: <5873D523.4030301@gmail.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <20170108171902.GH1971@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35562 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031638AbdAISXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:23:47 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so6083049pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:23:47 -0800 (PST)
In-Reply-To: <20170108171902.GH1971@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-08 09:19 AM, Jiri Pirko wrote:
> Mon, Jan 02, 2017 at 11:21:41PM CET, jhs@mojatatu.com wrote:
>> On 17-01-02 01:23 PM, John Fastabend wrote:
>>
>>>
>>> Additionally I would like to point out this is an arbitrary length binary
>>> blob (for undefined use, without even a specified encoding) that gets pushed
>>> between user space and hardware ;) This seemed to get folks fairly excited in
>>> the past.
>>>
>>
>> The binary blob size is a little strange - but i think there is value
>> in storing some "cookie" field. The challenge is whether the kernel
>> gets to intepret it; in which case encoding must be specified. Or
>> whether we should leave it up to user space - in which something
>> like tc could standardize its own encodings.
> 
> This should never be interpreted by kernel. I think this would be good
> to make clear in the comment in the code.
> 

Ah OK I had assumed you would be pushing this via tc_cls_flower_offload into
the driver in a follow up patch. But if it lives in kernel space as opaque
cookie guess its no different then other id fields order/prio/cookie.

Thanks for clarifying.
