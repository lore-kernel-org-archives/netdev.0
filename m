From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Mon, 11 Sep 2017 16:43:20 -0700
Message-ID: <CAM_iQpX3dpZHrcxt8irEHYeAEyGxw+S1GhVAX31gNTs89f0XPA@mail.gmail.com>
References: <20170906111419.5115-1-jiri@resnulli.us> <20170907.191800.218886770521884093.davem@davemloft.net>
 <CAM_iQpXSjXWPw9QY7VHGnKssLHCBSJq4XnS2KPTheLB7_rBF7g@mail.gmail.com> <20170910140338.GA1860@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36705 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdIKXnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 19:43:41 -0400
Received: by mail-pf0-f193.google.com with SMTP id f84so5528684pfj.3
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 16:43:41 -0700 (PDT)
In-Reply-To: <20170910140338.GA1860@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 10, 2017 at 7:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sat, Sep 09, 2017 at 08:46:42PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Thu, Sep 7, 2017 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> This doesn't apply cleanly any more, please respin.
>>>
>>
>>Sigh, you applied this patch despite of strong objections from me.
>>
>>I seriously doubt your tastes now, David. Fine, this code does not
>>deserve a good taste at all, let bugs stay there.
>
> Actually, the reported bug is resolved by this patch. I like your
> approach Cong, we can make it work and follow-up on this patch.
> Please stay calm and be patient...

OK. I already rebased my patches and sent v3.
