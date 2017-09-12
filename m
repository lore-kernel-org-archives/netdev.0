From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v3 1/3] net_sched: get rid of tcfa_rcu
Date: Tue, 12 Sep 2017 14:53:09 -0700
Message-ID: <CAM_iQpUwC6cMBOVuwgCsE+wL88OeL04qw2vSN7_Ng6_GCA5A=g@mail.gmail.com>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-2-xiyou.wangcong@gmail.com> <20170912094215.GB2036@nanopsycho>
 <20170912104004.GE2036@nanopsycho> <CAM_iQpWN+OFdWZgKsm8qk58jFKqssOMMW8JM7N6FConHumQXxg@mail.gmail.com>
 <20170912213634.GS2036@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35490 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdILVxa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 17:53:30 -0400
Received: by mail-pf0-f175.google.com with SMTP id q76so7021257pfq.2
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 14:53:30 -0700 (PDT)
In-Reply-To: <20170912213634.GS2036@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 2:36 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Sep 12, 2017 at 11:10:22PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Tue, Sep 12, 2017 at 3:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> This patch helps:
>>
>>Looks good to me. Please feel free to submit a formal patch.
>
> Okay, I will send the patch to you formally so you can add it as a first
> patch of your patchset.

I can carry it by myself if it fits to this patchset. However, I believe it
should be independent since it has to be backported much further
than this patchset. I don't know why no one triggered the crash
before call_rcu() was introduced there.

Anyway, I believe you should submit your patch alone, either before
or after this patchset, there should be no conflict.
