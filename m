From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 14:21:00 -0700 (PDT)
Message-ID: <20170811.142100.465766359895148878.davem@davemloft.net>
References: <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
        <20170811203246.GA32076@breakpoint.cc>
        <CAM_iQpUoa5vWfQGpqCJ7dXx542uC-5JyNpRK-zukVbq=EfAAEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, khlebnikov@yandex-team.ru, netdev@vger.kernel.org,
        jiri@mellanox.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753256AbdHKVVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:21:01 -0400
In-Reply-To: <CAM_iQpUoa5vWfQGpqCJ7dXx542uC-5JyNpRK-zukVbq=EfAAEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 11 Aug 2017 14:06:31 -0700

> On Fri, Aug 11, 2017 at 1:32 PM, Florian Westphal <fw@strlen.de> wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
>>> <khlebnikov@yandex-team.ru> wrote:
>>> > In previous API tcf_destroy_chain() could be called several times and
>>> > some schedulers like hfsc and atm use that. In new API tcf_block_put()
>>> > frees block but leaves stale pointer, second call will free it once again.
>>>
>>> Which call path do we call tcf_block_put() for multiple times on
>>> the same block? Please be specific, it is not obvious.
>>
>> you can use tools/testing/selftests/net/rtnetlink.sh to reproduce this
>> (kernel panics on delete of root qdisc).
> 
> I am sure this is not how changelog works. We have enough space
> in changelog to describe a bug, don't have to leave details in a
> following-up email which will almost surely be lost in history.

Yeah, the more information in the commit log message the better.
