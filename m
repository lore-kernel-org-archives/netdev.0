From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v9 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 15:47:18 +0200
Message-ID: <20170426134718.GA18251@nanopsycho>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
 <1493210538-21716-3-git-send-email-jhs@emojatatu.com>
 <20170426130844.GG1867@nanopsycho.orion>
 <5723f2e0-7738-09f5-23c0-bfe7432d7528@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36824 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432001AbdDZNrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:47:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id u65so1205784wmu.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:47:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5723f2e0-7738-09f5-23c0-bfe7432d7528@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 03:17:59PM CEST, jhs@mojatatu.com wrote:
>On 17-04-26 09:08 AM, Jiri Pirko wrote:
>> Wed, Apr 26, 2017 at 02:42:17PM CEST, jhs@mojatatu.com wrote:
>
>> > +#define VALID_TCA_ROOT_FLAGS TCA_FLAG_LARGE_DUMP_ON
>> > +static inline bool tca_flags_valid(u32 act_flags)
>> > +{
>> > +	u32 invalid_flags_mask  = ~VALID_TCA_ROOT_FLAGS;
>> > +
>> > +	if (act_flags & invalid_flags_mask)
>> > +		return false;
>> > +
>> > +	return true;
>> 
>> This dance should either not be here (flag-per-attr) or should be in
>> netlink generic place. This is not TC specific at all.
>> 
>
>So where do you think it should be?
>
>> I would still like to see the numbers prooving we need this.
>> Thanks
>> 
>
>We are going to have to agree to disagree.

No, I don't agree with this. All I'm asking is if the flag dance you do
is really necessary. This is important, UAPI, set in stone in future.
So please avoid the rush this. Don't send another version please.

Your argument is "performance", so I just asked for the proof that this  
argument is valid. I believe it is not. That's legit, right?              
Please proove me wrong and I'll be happy.
                                                                         
Thanks!
