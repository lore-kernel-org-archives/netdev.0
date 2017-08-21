From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net: sched: Add the invalid handle check in
 qdisc_class_find
Date: Mon, 21 Aug 2017 16:17:01 -0400
Message-ID: <13811d3e-9800-8277-c861-2fab9de8e4b9@mojatatu.com>
References: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
 <20170821.104749.419102990180912192.davem@davemloft.net>
 <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gao Feng <gfree.wind@vip.163.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36072 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdHUURE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 16:17:04 -0400
Received: by mail-io0-f195.google.com with SMTP id o196so1768992ioe.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 13:17:03 -0700 (PDT)
In-Reply-To: <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-21 03:58 PM, Cong Wang wrote:
> On Mon, Aug 21, 2017 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
>> From: gfree.wind@vip.163.com
>> Date: Fri, 18 Aug 2017 15:23:24 +0800
>>
>>> From: Gao Feng <gfree.wind@vip.163.com>
>>>
>>> Add the invalid handle "0" check to avoid unnecessary search, because
>>> the qdisc uses the skb->priority as the handle value to look up, and
>>> it is "0" usually.
>>>
>>> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
>>
>> Jamal, Cong, please review.
>>
>> If 'id' zero is never hashed into the tables, this change looks
>> legitimate.
> 
> Looks good to me.
>

Looks good to me as well...

cheers,
jamal
