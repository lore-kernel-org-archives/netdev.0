From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Date: Fri, 3 Mar 2017 07:22:33 -0800
Message-ID: <CANn89i+E+DkUJBV-3AQ38hstj9=G7=3fLJuG8LA6upp77ecwPA@mail.gmail.com>
References: <CAAeHK+xDhUDe9_-uEakJG9iqTtD_+fFr+JyUbkWCHHLBCcu1uQ@mail.gmail.com>
 <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
 <CACT4Y+YUJGsvzFuFT3r0M-3KbPrcx62fzSHHQX=B43-syLYU0A@mail.gmail.com>
 <1488551576.9415.328.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488552503.9415.330.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com> <CACT4Y+ZhNzcKTODGkD3R-68KgkOtYCaf4cZYPH51=HhREXVPGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZhNzcKTODGkD3R-68KgkOtYCaf4cZYPH51=HhREXVPGg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 7:12 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> The first bot that picked this up started spewing:
>
> BUG: spinlock recursion on CPU#1, syz-executor2/9452

Yes. The bug is not about locking the listener, but protecting fields
of struct dccp_request_sock

I will provide a patch, once I reach the office and after the breakfast ;)
