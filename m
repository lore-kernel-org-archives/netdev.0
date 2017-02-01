From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Wed, 01 Feb 2017 13:22:43 -0800
Message-ID: <1485984163.6360.160.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
         <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
         <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
         <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
         <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36517 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdBAVWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 16:22:45 -0500
In-Reply-To: <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 13:16 -0800, Eric Dumazet wrote:

> This would permanently leave the kernel in the netstamp_needed state.
> 
> I would prefer the patch using a process context to perform the
> cleanup ? Note there is a race window, but probably not a big deal.
> 
>  net/core/dev.c |   30 ++++++++++--------------------
>  1 file changed, 10 insertions(+), 20 deletions(-)

Patch is not complete (for the HAVE_JUMP_LABEL=n case)

Would you like to author/submit it ?

Thanks.
