From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 15:05:06 +0200
Message-ID: <20170426130506.GF1867@nanopsycho.orion>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <20170426110241.GA28251@vergenet.net>
 <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32796 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000037AbdDZNFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:05:09 -0400
Received: by mail-wr0-f193.google.com with SMTP id w50so24701049wrc.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:05:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 02:46:22PM CEST, jhs@mojatatu.com wrote:
>On 17-04-26 07:02 AM, Simon Horman wrote:
>> On Tue, Apr 25, 2017 at 06:04:45PM +0200, Jiri Pirko wrote:
>[..]
>
>> > So fix iproute2. It is always first kernel, then iproute2.
>> 
>> Perhaps I am missing the point or somehow misguided but I would expect that
>> if the UAPI uses BIT() it also provides BIT().
>
>There is a user of BIT() already in iproute2 (devlink). We can move
>the code to be more generally available for other iproute2 users.
>Then this UAPI change makes use of it.

Should be part of UAPI as well
I see that include/uapi/rdma/vmw_pvrdma-abi.h is using BIT macro.
I don't see BIT macro defined in UAPI (I thought it is). So either
define it there (not sure where) or just use "<<"
