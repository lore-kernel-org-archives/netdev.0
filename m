From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: sched: Add the invalid handle check in qdisc_class_find
Date: Mon, 21 Aug 2017 12:58:03 -0700
Message-ID: <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
References: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com> <20170821.104749.419102990180912192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Gao Feng <gfree.wind@vip.163.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35215 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754046AbdHUT6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 15:58:25 -0400
Received: by mail-pg0-f68.google.com with SMTP id m133so5804656pga.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 12:58:24 -0700 (PDT)
In-Reply-To: <20170821.104749.419102990180912192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
> From: gfree.wind@vip.163.com
> Date: Fri, 18 Aug 2017 15:23:24 +0800
>
>> From: Gao Feng <gfree.wind@vip.163.com>
>>
>> Add the invalid handle "0" check to avoid unnecessary search, because
>> the qdisc uses the skb->priority as the handle value to look up, and
>> it is "0" usually.
>>
>> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
>
> Jamal, Cong, please review.
>
> If 'id' zero is never hashed into the tables, this change looks
> legitimate.

Looks good to me.

Gao, in the future please Cc maintainers directly, you can
use ./scripts/get_maintainer.pl.

Thanks.
