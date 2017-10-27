From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING in refcount_sub_and_test
Date: Fri, 27 Oct 2017 02:36:41 -0700
Message-ID: <1509097001.11887.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <001a11441d867b940f055c4c0b40@google.com>
         <CAOm2TWwoJhsT==euSyC0EDCbWXzTVWBBmvbX8HgmdjxvW0wVbw@mail.gmail.com>
         <CACT4Y+bWsMoMOY6A5f0RLqRBGKwmELCrQUJhxPzkpHasdrn=5A@mail.gmail.com>
         <CADvbK_eHVY8LvSReDiXmt3qxOWdLgQQ1ugkZi6C3DrskuUoBtg@mail.gmail.com>
         <CACT4Y+YegVs8c75nJ5caFPiz8wctj_7n-C3F=RC5PVE1R2uDOQ@mail.gmail.com>
         <CADvbK_dNGc5K1+Ne-JWaLGn1o4EsmEw60GLk92jJ2C3DWuqdpA@mail.gmail.com>
         <CACT4Y+aEkksuWQ3YPUfjZaSoWq01LxpkkdrLO83s7H50+0Lj5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>, ChunYu Wang <chunwang@redhat.com>,
        syzbot
        <bot+a004c8dcbae7c160bf1bbd6e6af2e9cf4fa54f84@syzkaller.appspotmail.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        syzkaller-bugs@googlegroups.com,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aEkksuWQ3YPUfjZaSoWq01LxpkkdrLO83s7H50+0Lj5g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-10-27 at 08:09 +0200, Dmitry Vyukov wrote:

> Yes, I've noticed this one. It seems to happen on a first incoming
> network connection (ssh/scp). I have not seen it before.

https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=timers/core&id=52f737c2da40259ac9962170ce608b6fb1b55ee4

( Google-Bug-Id: 68003409 )
