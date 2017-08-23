From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: kill u32_node pointer in Qdisc
Date: Wed, 23 Aug 2017 14:14:15 -0700
Message-ID: <CAM_iQpXx4BnkOQPBu7G12BAnGB_W18=dSJRjg206K6ek+8=o8g@mail.gmail.com>
References: <20170823175854.21924-1-xiyou.wangcong@gmail.com> <20170823202553.GC2015@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37534 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdHWVOg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:14:36 -0400
Received: by mail-pg0-f50.google.com with SMTP id y129so5379087pgy.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 14:14:36 -0700 (PDT)
In-Reply-To: <20170823202553.GC2015@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 1:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>+static struct hlist_head *tc_u_common_hash;
>
> Why not use rhashtable?
>

It doesn't have to be so complicated, it is not fast path and
we don't have so many qdisc's and u32 filters in system
relatively.


>>+      tc_u_common_hash = kvmalloc_array(U32_HASH_SIZE, sizeof(struct hlist_head), GFP_KERNEL);
>
> This is over 80cols.
>

Yeah, it doesn't harm anything, but I can fix it.
