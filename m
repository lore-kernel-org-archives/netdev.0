From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 11:58:59 -0700
Message-ID: <CAHA+R7MYoK_9nn+-aVgR7s-QFnPj3SGr51bEAB2vYzFjU_Qh6w@mail.gmail.com>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
	<544A913A.1060100@gmail.com>
	<CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: wang.bo116@zte.com.cn, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:37486 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaJXS7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 14:59:00 -0400
Received: by mail-qc0-f175.google.com with SMTP id b13so1349584qcw.34
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 11:58:59 -0700 (PDT)
In-Reply-To: <CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 11:13 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Fri, Oct 24, 2014 at 10:49 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>> Patch looks fine, another way to fix this would be drop the
>> mq_destroy() call in the error path. I'm not convinced one
>> is any better than the other but maybe some other folks have
>> opinions, it seems a bit wrong to call mq_destroy twice so in
>> that sense it may be a bit nicer to drop the mq_destroy().
>
> Dropping mq_destroy() in error path is indeed better,
> because upper layer does cleanup intentionally.
> Look at what other qdisc's do. :)


Anyway, I am fixing other qdisc's now, will leave mq and
mq_prio to you.

Thanks.
