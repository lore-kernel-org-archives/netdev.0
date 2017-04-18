From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: use-after-free in ip_queue_xmit
Date: Tue, 18 Apr 2017 19:45:04 +0200
Message-ID: <CAAeHK+w+DcYC8NVSCJeX-=8H7OYeEpeMU4n8y7-ofPVCorwqqg@mail.gmail.com>
References: <CAAeHK+z5=b4PdSrq8ff-btYbd-aKFR+uzQnoC5Pq4du4uVQjzQ@mail.gmail.com>
 <CAM_iQpWsEpJYHG1WvC9kQPt8iezBuLC8PeSqM20=W9cpkRE6=Q@mail.gmail.com>
 <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com>
 <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com>
 <CAM_iQpU_frn6bB6HHrRrF6omKDoXjxZmSoJZSu=PjZ35pUVOuA@mail.gmail.com>
 <CAAeHK+wYLwZqGWjBNbw6mbvTiHCeXC91dYmMY410YwprU8OG1w@mail.gmail.com> <CAM_iQpVXKA6S2Nc1+UAW6q5X-iiSCU3UQaAsCm2SAkA5Axct+A@mail.gmail.com>
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33261 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754503AbdDRRpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:45:05 -0400
Received: by mail-pg0-f47.google.com with SMTP id 63so80540pgh.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:45:05 -0700 (PDT)
In-Reply-To: <CAM_iQpVXKA6S2Nc1+UAW6q5X-iiSCU3UQaAsCm2SAkA5Axct+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 6:05 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Apr 18, 2017 at 5:15 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Yes, I don't have this field in the rtable struct.
>>
>> I'm on 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>>
>> I also don't see it in the cross reference:
>> http://lxr.free-electrons.com/source/include/net/route.h#L51
>>
>
> It is provided by my patch: https://patchwork.ozlabs.org/patch/747556/
> which means you applied an incomplete patch... :-/

Oops, my bad.

Applied the patch.

Thanks!
