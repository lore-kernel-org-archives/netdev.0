From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Wed, 25 Oct 2017 13:46:57 -0700
Message-ID: <CAM_iQpXrVM=N22h7kfUSut44WXZZkGwBusj7zsxk0QmtKy7Rtg@mail.gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <1508800599.30291.106.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUXr-3rAkBiVFvZ5YSRG=ZrPEWzQwQYZ0Yx_YP_BQNGoA@mail.gmail.com> <1508801477.30291.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:51829 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYUrS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 16:47:18 -0400
Received: by mail-pg0-f67.google.com with SMTP id p9so894247pgc.8
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 13:47:18 -0700 (PDT)
In-Reply-To: <1508801477.30291.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 4:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I did not pretend to give a bug fix, I simply said your patch series was
> probably not the right way.

Generally I agree with you on avoid synchronize_rcu(), but this case
is very special, you need to consider case by case, not just talking
generally.


>
> Sure, we could add back BKL and solve a lot of lockdep issues.
>
>

For the record, this case is about race conditions which lead to
real bugs, not merely lockdep warnings.
