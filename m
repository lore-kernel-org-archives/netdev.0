From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Mon, 26 Sep 2016 05:29:05 -0400
Message-ID: <d922736e-268a-9017-c03a-c635bb4ebffe@mojatatu.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
 <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com>
 <CAM_iQpVBhckM4f43T0Lc2Bt28nVFBAjORHt5d=1_m9AfoPJtSg@mail.gmail.com>
 <CAJL1qvGnPsjbzp9Z_6GkXzJqrxAAgYY6uE_0mCWb=H-EhcB8-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35128 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759791AbcIZJ3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:29:08 -0400
Received: by mail-io0-f170.google.com with SMTP id m186so175757889ioa.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:29:07 -0700 (PDT)
In-Reply-To: <CAJL1qvGnPsjbzp9Z_6GkXzJqrxAAgYY6uE_0mCWb=H-EhcB8-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-26 02:02 AM, Hadar Hen Zion wrote:
> On Mon, Sep 26, 2016 at 7:31 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

>>
>> The reason is we use action->order as an nested attribute, so
>> the order in the list doesn't matter, only action->order itself matters.
>
> The order in the list matters for offload drivers who use the
> "tcf_exts_to_list" function and action->order parameter isn't usable
> for them.

Ok, thanks for the explanation.

> Why not keeping the actions in the same order as the user? isn't it
> more elegant?
>

I dont think it was intentional. I will ACK the patch.

cheers,
jamal
