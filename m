From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 17:13:53 +0200
Message-ID: <20170420151353.GB19004@nanopsycho.orion>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <67dc8e10-b0df-c0c5-7c46-ac4147c1c797@mojatatu.com>
 <20170420143313.GA19004@nanopsycho.orion>
 <7e9dbb08-fb80-aee6-a0d0-dce56cbfd7c3@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33571 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970326AbdDTPN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:13:57 -0400
Received: by mail-wr0-f196.google.com with SMTP id w50so3170680wrc.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:13:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7e9dbb08-fb80-aee6-a0d0-dce56cbfd7c3@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 20, 2017 at 05:08:20PM CEST, jhs@mojatatu.com wrote:
>On 17-04-20 10:33 AM, Jiri Pirko wrote:
>> Thu, Apr 20, 2017 at 04:25:11PM CEST, jhs@mojatatu.com wrote:
>
>> > > TCAA stands for "traffic control action action". I don't get it :(
>> > 
>> > TC Action Attributes == TCAA.
>> > 
>> > > Prefix still sounds wrong to me, sorry :/
>> > > Should be:
>> > > TCA_SOMETHING_*
>> > > 
>> > 
>> > TCA_ATTR_XXX ?
>> 
>> Of course it is an attribute. No need to have "attr" in the name. No
>> other enum has it. Does not make sense.
>> 
>> The name should contain the group name. What group this enum defines?
>> 
>
>It defines tc root level Action attributes.
>Would TCRLAA_XXX be more exciting? ;->

How about TCA_ROOT_XXX


>
>cheers,
>jamal
>
