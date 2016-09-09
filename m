From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 8 Sep 2016 22:59:29 -0700
Message-ID: <CAM_iQpUxLYG-8kc+frLZ5QD85m22gPQGJGqnKpLXjG-Qa2Goow@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com> <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUxLDa1yQMDvCH760xGOsDMYz9wvHro64VYamnhXE=+yA@mail.gmail.com> <20160909054810.GA66323@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35008 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbcIIF7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:59:50 -0400
Received: by mail-oi0-f46.google.com with SMTP id s131so115294611oie.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:59:50 -0700 (PDT)
In-Reply-To: <20160909054810.GA66323@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 10:48 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
>
> imo the deliberate small race in Eric's initial lock removal in mirred
> was a good design choice. I think he did this patch only to
> silence the complains with the code instead of arguing with words.
> imo the initial code is good as-is. This patch is also a nice improvement,
> but certainly not mandatory. 'face palm' is unnecessary.

LOL, to summarize your words:

1) not changing the current code is good
2) changing the current code is good too
