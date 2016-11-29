From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: deadlock on genl_mutex
Date: Mon, 28 Nov 2016 22:06:00 -0800
Message-ID: <1480399560.18162.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
         <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
         <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        syzkaller <syzkaller@googlegroups.com>,
        netdev-owner@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36398 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752706AbcK2GGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:06:02 -0500
In-Reply-To: <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 22:59 -0700, subashab@codeaurora.org wrote:
> > 
> > Issue was reported yesterday and is under investigation.
> > 
> > 
> > http://marc.info/?l=linux-netdev&m=148014004331663&w=2
> > 
> > 
> > Thanks !
> 
> Hi Dmitry
> 
> Can you try the patch below with your reproducer? I haven't seen similar 
> crashes reported after this (or even with Eric's patch).
> 
> https://patchwork.ozlabs.org/patch/699937/

Yeah, I will post my patch on top of this one.
