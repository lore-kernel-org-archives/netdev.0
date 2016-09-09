From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Thu, 8 Sep 2016 22:54:33 -0700
Message-ID: <CAM_iQpXJFwtEwWLbL6umapCY-_pkNy0xTyjvkbXQVFJGFWaOcQ@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com> <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D18894.2070702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33615 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbcIIFyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:54:55 -0400
Received: by mail-oi0-f53.google.com with SMTP id y2so118959472oie.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:54:54 -0700 (PDT)
In-Reply-To: <57D18894.2070702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 8:49 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> Agreed not sure why you would ever want to do a late binding and
> replace on a tc_mirred actions. But it is supported...

I will let Jamal teach you on this, /me is really tired of explaining
things to you John.
