From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 08:46:22 -0400
Message-ID: <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <20170426110241.GA28251@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35866 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431790AbdDZMqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 08:46:25 -0400
Received: by mail-io0-f195.google.com with SMTP id x86so302570ioe.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 05:46:24 -0700 (PDT)
In-Reply-To: <20170426110241.GA28251@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 07:02 AM, Simon Horman wrote:
> On Tue, Apr 25, 2017 at 06:04:45PM +0200, Jiri Pirko wrote:
[..]

>> So fix iproute2. It is always first kernel, then iproute2.
>
> Perhaps I am missing the point or somehow misguided but I would expect that
> if the UAPI uses BIT() it also provides BIT().

There is a user of BIT() already in iproute2 (devlink). We can move
the code to be more generally available for other iproute2 users.
Then this UAPI change makes use of it.

cheers,
jamal
