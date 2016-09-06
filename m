From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 1/6] net_sched: use RCU for action hash table
Date: Tue, 6 Sep 2016 15:37:49 -0700
Message-ID: <CAM_iQpVbrjYA8bzNKZ56xNA-2U64nxE_ifDrfzXbgskFM1sA4A@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-2-git-send-email-xiyou.wangcong@gmail.com> <1e33ca48-5c03-232b-9700-56a0510700b8@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33053 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933672AbcIFWiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 18:38:10 -0400
Received: by mail-oi0-f68.google.com with SMTP id w78so11834018oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 15:38:10 -0700 (PDT)
In-Reply-To: <1e33ca48-5c03-232b-9700-56a0510700b8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 5:47 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-02 01:57 AM, Cong Wang wrote:
>>
>> We already free tc actions in a RCU callback, so here
>> we just need to convert the hash table operations to
>> RCU API's.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>
> This one stands on its own merit, no?

Yes, I think so. I think it is fine to carry it in this patchset too.


> So:
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>

Thanks.
