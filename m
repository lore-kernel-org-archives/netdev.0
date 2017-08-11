From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 14:06:31 -0700
Message-ID: <CAM_iQpUoa5vWfQGpqCJ7dXx542uC-5JyNpRK-zukVbq=EfAAEA@mail.gmail.com>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com> <20170811203246.GA32076@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38467 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753821AbdHKVGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:06:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id h75so4359035pfh.5
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 14:06:52 -0700 (PDT)
In-Reply-To: <20170811203246.GA32076@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 1:32 PM, Florian Westphal <fw@strlen.de> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>> > In previous API tcf_destroy_chain() could be called several times and
>> > some schedulers like hfsc and atm use that. In new API tcf_block_put()
>> > frees block but leaves stale pointer, second call will free it once again.
>>
>> Which call path do we call tcf_block_put() for multiple times on
>> the same block? Please be specific, it is not obvious.
>
> you can use tools/testing/selftests/net/rtnetlink.sh to reproduce this
> (kernel panics on delete of root qdisc).

I am sure this is not how changelog works. We have enough space
in changelog to describe a bug, don't have to leave details in a
following-up email which will almost surely be lost in history.
