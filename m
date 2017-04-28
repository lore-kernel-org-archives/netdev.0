From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Apr 2017 15:21:46 +0200
Message-ID: <20170428132146.GE1886@nanopsycho.orion>
References: <20170426110241.GA28251@vergenet.net>
 <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
 <20170426130506.GF1867@nanopsycho.orion>
 <20170426.104658.547156121898948265.davem@davemloft.net>
 <20170428122131.GC19353@vergenet.net>
 <9dbd92e4-506d-5267-9542-ae92a0511a4c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34033 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969389AbdD1NVt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:21:49 -0400
Received: by mail-wm0-f66.google.com with SMTP id z129so10931518wmb.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 06:21:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <9dbd92e4-506d-5267-9542-ae92a0511a4c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 02:55:40PM CEST, jhs@mojatatu.com wrote:
>On 17-04-28 08:21 AM, Simon Horman wrote:
>> On Wed, Apr 26, 2017 at 10:46:58AM -0400, David Miller wrote:
>> > From: Jiri Pirko <jiri@resnulli.us>
>> > Date: Wed, 26 Apr 2017 15:05:06 +0200
>> > 
>
>[..]
>> > > Should be part of UAPI as well
>> > > I see that include/uapi/rdma/vmw_pvrdma-abi.h is using BIT macro.
>> > > I don't see BIT macro defined in UAPI (I thought it is). So either
>> > > define it there (not sure where) or just use "<<"
>> > 
>> > "BIT" is a pretty crazy small simple name to pollute into the global
>> > namespace, IMHO.
>> 
>> It sounds to me that it would be best to just use "<<" rather than
>> spending cycles posturing on how to add it to the UAPI. Existing users
>> of BIT in the UAPI could also be updated to use "<<" to avoid having
>> a misleading precedence in-tree.
>> 
>
>We need to convince Jiri ;-> He has plans to do a lot of cleanups and
>I feel like I am pioneering (A lot of new things on my patchset).
>Jiri, could this come in your cleanups later?
 
Sure.

>
>cheers,
>jamal
