From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Tue, 27 Sep 2016 10:46:59 +0300
Message-ID: <CAJL1qvGy+sxLrspwXb+mZM_F=u3qu6AQPQ6tffGg4n6K8nMtVA@mail.gmail.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
 <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com> <CAM_iQpVBhckM4f43T0Lc2Bt28nVFBAjORHt5d=1_m9AfoPJtSg@mail.gmail.com>
 <CAJL1qvGnPsjbzp9Z_6GkXzJqrxAAgYY6uE_0mCWb=H-EhcB8-A@mail.gmail.com> <CAM_iQpUxCU3S3sryGxnWBQKs6bOeVP49JotdFRur69-VV4+HzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34092 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbcI0HrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:47:00 -0400
Received: by mail-oi0-f48.google.com with SMTP id a62so6378237oib.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 00:47:00 -0700 (PDT)
In-Reply-To: <CAM_iQpUxCU3S3sryGxnWBQKs6bOeVP49JotdFRur69-VV4+HzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 11:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Sep 25, 2016 at 11:02 PM, Hadar Hen Zion
> <hadarh@dev.mellanox.co.il> wrote:
>> On Mon, Sep 26, 2016 at 7:31 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Sun, Sep 25, 2016 at 7:39 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>>> On 16-09-25 10:08 AM, Hadar Hen Zion wrote:
>>>>>
>>>>> Currently the created tc actions list is reversed against the order
>>>>> set by the user.
>>>>> Change the actions list order to be the same as was set by the user.
>>>>>
>>>>
>>>>
>>>> Did something break? It seems to matter most for dumping. But even that
>>>> didnt breaking. Looking at the latest net tree, i tried:
>>>>
>>>
>>> The reason is we use action->order as an nested attribute, so
>>> the order in the list doesn't matter, only action->order itself matters.
>>
>> The order in the list matters for offload drivers who use the
>> "tcf_exts_to_list" function and action->order parameter isn't usable
>> for them.
>> Why not keeping the actions in the same order as the user? isn't it
>> more elegant?
>
> I don't object this patch since it affects offloading, I just explained
> why it doesn't affect dumping.
>
> Please add this to your changelog, to make it obvious.

Sure, I'll add it.

Hadar

>
> Thanks!
