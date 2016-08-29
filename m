From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 28 Aug 2016 22:10:03 -0700
Message-ID: <CAM_iQpUPsqL7eee1Pp1LgRVssmbBGekKMMqsUrWQbDz1Nz4Xzg@mail.gmail.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com> <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32807 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbcH2FLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 01:11:07 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so7953438wme.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 22:10:25 -0700 (PDT)
In-Reply-To: <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 9:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Adding an action with a spinlock held in fast path in 2016 is
> a way to tell people : It is a toy, do not use it for real.
>
> Sorry guys. Friends do not let friends do that anymore.
>

Please stop joking, this is not funny at all:

% git grep tcf_lock -- net/sched
