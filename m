From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Tue, 10 Jan 2017 09:55:55 -0800
Message-ID: <CAM_iQpVvO3W41WRiAsX7_cZLZkgqAemw4T229FdvyhVYMn6CSw@mail.gmail.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
 <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com> <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34548 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932157AbdAJR4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:56:22 -0500
In-Reply-To: <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 9:40 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Tue, Jan 10, 2017 at 9:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Jan 9, 2017 at 9:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>
>> The fix should be straight-forward. Mind to try the attached patch?
>
>
> You forgot to remove schedule() ?
>
>   schedule();
> + wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);

Ah, of course, never even compile it... :-/
