From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 5/7] net/sched: cls_matchall: Reflect HW
 offloading status
Date: Wed, 15 Feb 2017 23:40:02 +0200
Message-ID: <CAJ3xEMi7EeEA=y-fGCOGCpk52kes+d=522zapH0pv2usTZMKXg@mail.gmail.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
 <1487148757-24809-6-git-send-email-ogerlitz@mellanox.com> <20170215.131556.2072311430827899930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34901 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbdBOVkD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 16:40:03 -0500
Received: by mail-oi0-f67.google.com with SMTP id x84so460033oix.2
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:40:03 -0800 (PST)
In-Reply-To: <20170215.131556.2072311430827899930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 8:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 15 Feb 2017 10:52:35 +0200
>
>> @@ -194,6 +199,9 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
>>               }
>>       }
>>
>> +     if (!(tc_in_hw(new->flags)))
>> +             new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
>
> Too many parenthesis, please make this:
>
>         if (!tc_in_hw(new->flags))
>                 new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;

OKay, Dave, I will fix that along with the other places
