From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv6: use-after-free in sock_wfree
Date: Mon, 9 Jan 2017 11:08:34 -0800
Message-ID: <CANn89i+XuBC0OnN_sHX0LS_Wu-EHNrXVKdpXmPXFCmMujeiO3g@mail.gmail.com>
References: <CAAeHK+yfNdNTkgCbUGbdRBM9bB=2DhGv1ZPCWm44CGL7zD=TLg@mail.gmail.com>
 <CAAeHK+yiziBBxw3JMqec3c7aLXjk6ddL2Xh1xufA3sp5ja=_TA@mail.gmail.com>
 <CANn89iLX+GPK6WWcz76T_z4_hMv4aNy8nREVqGKP-q+UqQNOxA@mail.gmail.com> <CAAeHK+y3W7O3Uanr3=2rnew+unabjt6+SCAMebq1RVKsJ0QkDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y3W7O3Uanr3=2rnew+unabjt6+SCAMebq1RVKsJ0QkDw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 9, 2017 at 11:06 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>
> Hi Eric,
>
> This patch fixes the issue.
>
> Thanks!

Thanks Andrey.

Could you please post your .config for next KASAN reports ?

I am asking this because I could not reproduce the issue with my own
builds, so I had to guess but could not test the fix myself.

Thanks !
