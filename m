From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: use-after-free in ip_queue_xmit
Date: Tue, 18 Apr 2017 09:05:43 -0700
Message-ID: <CAM_iQpVXKA6S2Nc1+UAW6q5X-iiSCU3UQaAsCm2SAkA5Axct+A@mail.gmail.com>
References: <CAAeHK+z5=b4PdSrq8ff-btYbd-aKFR+uzQnoC5Pq4du4uVQjzQ@mail.gmail.com>
 <CAM_iQpWsEpJYHG1WvC9kQPt8iezBuLC8PeSqM20=W9cpkRE6=Q@mail.gmail.com>
 <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com>
 <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com>
 <CAM_iQpU_frn6bB6HHrRrF6omKDoXjxZmSoJZSu=PjZ35pUVOuA@mail.gmail.com> <CAAeHK+wYLwZqGWjBNbw6mbvTiHCeXC91dYmMY410YwprU8OG1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wYLwZqGWjBNbw6mbvTiHCeXC91dYmMY410YwprU8OG1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 5:15 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Yes, I don't have this field in the rtable struct.
>
> I'm on 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>
> I also don't see it in the cross reference:
> http://lxr.free-electrons.com/source/include/net/route.h#L51
>

It is provided by my patch: https://patchwork.ozlabs.org/patch/747556/
which means you applied an incomplete patch... :-/
