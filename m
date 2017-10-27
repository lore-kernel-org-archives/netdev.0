From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: WARNING in refcount_sub_and_test
Date: Fri, 27 Oct 2017 11:43:17 +0200
Message-ID: <CACT4Y+bjFj6-G_WxetFzmWfppjZLOXHk2G2m_XfEZpC3h4k0Tw@mail.gmail.com>
References: <001a11441d867b940f055c4c0b40@google.com> <CAOm2TWwoJhsT==euSyC0EDCbWXzTVWBBmvbX8HgmdjxvW0wVbw@mail.gmail.com>
 <CACT4Y+bWsMoMOY6A5f0RLqRBGKwmELCrQUJhxPzkpHasdrn=5A@mail.gmail.com>
 <CADvbK_eHVY8LvSReDiXmt3qxOWdLgQQ1ugkZi6C3DrskuUoBtg@mail.gmail.com>
 <CACT4Y+YegVs8c75nJ5caFPiz8wctj_7n-C3F=RC5PVE1R2uDOQ@mail.gmail.com>
 <CADvbK_dNGc5K1+Ne-JWaLGn1o4EsmEw60GLk92jJ2C3DWuqdpA@mail.gmail.com>
 <CACT4Y+aEkksuWQ3YPUfjZaSoWq01LxpkkdrLO83s7H50+0Lj5g@mail.gmail.com> <1509097001.11887.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>, ChunYu Wang <chunwang@redhat.com>,
        syzbot
        <bot+a004c8dcbae7c160bf1bbd6e6af2e9cf4fa54f84@syzkaller.appspotmail.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        syzkaller-bugs@googlegroups.com,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:53731 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752114AbdJ0Jni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 05:43:38 -0400
Received: by mail-io0-f194.google.com with SMTP id 189so11462463iow.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 02:43:38 -0700 (PDT)
In-Reply-To: <1509097001.11887.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 11:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-10-27 at 08:09 +0200, Dmitry Vyukov wrote:
>
>> Yes, I've noticed this one. It seems to happen on a first incoming
>> network connection (ssh/scp). I have not seen it before.
>
> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=timers/core&id=52f737c2da40259ac9962170ce608b6fb1b55ee4
>
> ( Google-Bug-Id: 68003409 )

Good!
I've noticed that it does not happen on latest Linus tree, now I know why.
