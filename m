From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: kill u32_node pointer in Qdisc
Date: Wed, 23 Aug 2017 14:31:23 -0700
Message-ID: <CAM_iQpXHg4jd4vtq0O3uAV6ONYA18M0MqJRs=P=FAmyCyf1eFA@mail.gmail.com>
References: <20170823175854.21924-1-xiyou.wangcong@gmail.com>
 <20170823202553.GC2015@nanopsycho> <CAM_iQpXx4BnkOQPBu7G12BAnGB_W18=dSJRjg206K6ek+8=o8g@mail.gmail.com>
 <20170823212056.GA22713@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36485 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdHWVbo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:31:44 -0400
Received: by mail-pg0-f45.google.com with SMTP id 83so5649921pgb.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 14:31:44 -0700 (PDT)
In-Reply-To: <20170823212056.GA22713@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 2:20 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Aug 23, 2017 at 11:14:15PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Wed, Aug 23, 2017 at 1:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>+static struct hlist_head *tc_u_common_hash;
>>>
>>> Why not use rhashtable?
>>>
>>
>>It doesn't have to be so complicated, it is not fast path and
>>we don't have so many qdisc's and u32 filters in system
>>relatively.
>
> Well, it is easier to work with. So why not use it?
>

OMG... You must have a different definition for "easier".


>
>>
>>
>>>>+      tc_u_common_hash = kvmalloc_array(U32_HASH_SIZE, sizeof(struct hlist_head), GFP_KERNEL);
>>>
>>> This is over 80cols.
>>>
>>
>>Yeah, it doesn't harm anything, but I can fix it.
>
> At least checkpatch warns you about it.

Not every checkpatch.pl warning worth your time.

Jiri, spend your time on something more value than
80-cols. ;)
