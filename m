From: subashab@codeaurora.org
Subject: Re: net: deadlock on genl_mutex
Date: Mon, 28 Nov 2016 22:59:28 -0700
Message-ID: <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
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
To: Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38088 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755006AbcK2F7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 00:59:30 -0500
In-Reply-To: <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Issue was reported yesterday and is under investigation.
> 
> 
> http://marc.info/?l=linux-netdev&m=148014004331663&w=2
> 
> 
> Thanks !

Hi Dmitry

Can you try the patch below with your reproducer? I haven't seen similar 
crashes reported after this (or even with Eric's patch).

https://patchwork.ozlabs.org/patch/699937/
