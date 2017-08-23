From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: kill u32_node pointer in Qdisc
Date: Wed, 23 Aug 2017 23:20:56 +0200
Message-ID: <20170823212056.GA22713@nanopsycho>
References: <20170823175854.21924-1-xiyou.wangcong@gmail.com>
 <20170823202553.GC2015@nanopsycho>
 <CAM_iQpXx4BnkOQPBu7G12BAnGB_W18=dSJRjg206K6ek+8=o8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:33244 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdHWV21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:28:27 -0400
Received: by mail-wr0-f175.google.com with SMTP id a47so4399910wra.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 14:28:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXx4BnkOQPBu7G12BAnGB_W18=dSJRjg206K6ek+8=o8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 23, 2017 at 11:14:15PM CEST, xiyou.wangcong@gmail.com wrote:
>On Wed, Aug 23, 2017 at 1:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>+static struct hlist_head *tc_u_common_hash;
>>
>> Why not use rhashtable?
>>
>
>It doesn't have to be so complicated, it is not fast path and
>we don't have so many qdisc's and u32 filters in system
>relatively.

Well, it is easier to work with. So why not use it?


>
>
>>>+      tc_u_common_hash = kvmalloc_array(U32_HASH_SIZE, sizeof(struct hlist_head), GFP_KERNEL);
>>
>> This is over 80cols.
>>
>
>Yeah, it doesn't harm anything, but I can fix it.

At least checkpatch warns you about it.
