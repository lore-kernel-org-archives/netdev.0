From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 8 Sep 2016 22:24:32 -0700
Message-ID: <CAM_iQpUxLDa1yQMDvCH760xGOsDMYz9wvHro64VYamnhXE=+yA@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com> <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36814 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbcIIFYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:24:53 -0400
Received: by mail-oi0-f47.google.com with SMTP id q188so2514065oia.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:24:53 -0700 (PDT)
In-Reply-To: <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 8:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> As reported by Cong Wang, I was lazy when I did initial RCU conversion
> of tc_mirred, as I thought I could avoid allocation/freeing of a
> parameter block.

Quote from Eric Dumazet:

https://www.mail-archive.com/netdev@vger.kernel.org/msg115482.html

<Quote>
Well, I added a READ_ONCE() to read tcf_action once.

Adding rcu here would mean adding a pointer and extra cache line, to
deref the values.

IMHO the race here has no effect . You either read the old or new value.
</Quote>

Me with facepalm... ;-)
