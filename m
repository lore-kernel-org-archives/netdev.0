From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 06:27:53 -0700
Message-ID: <1472477273.14381.257.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUPsqL7eee1Pp1LgRVssmbBGekKMMqsUrWQbDz1Nz4Xzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32876 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932942AbcH2N14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:27:56 -0400
Received: by mail-pa0-f67.google.com with SMTP id vy10so8997011pac.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 06:27:56 -0700 (PDT)
In-Reply-To: <CAM_iQpUPsqL7eee1Pp1LgRVssmbBGekKMMqsUrWQbDz1Nz4Xzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-08-28 at 22:10 -0700, Cong Wang wrote:
> On Sun, Aug 28, 2016 at 9:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Adding an action with a spinlock held in fast path in 2016 is
> > a way to tell people : It is a toy, do not use it for real.
> >
> > Sorry guys. Friends do not let friends do that anymore.
> >
> 
> Please stop joking, this is not funny at all:
> 
> % git grep tcf_lock -- net/sched

This is absolutely trivial to write this skbmod without taking a lock.

If you guys do not care about that, I will simply NACK any new lazy
code.

Do not try to call me funny, simply acknowledge the mere facts and try
to keep your calm Cong.
