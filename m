From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv4: division by 0 in tcp_select_window
Date: Fri, 3 Mar 2017 10:25:59 -0800
Message-ID: <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
References: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36570 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdCCS1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:27:18 -0500
Received: by mail-it0-f42.google.com with SMTP id h10so17988659ith.1
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 10:26:05 -0800 (PST)
In-Reply-To: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 10:10 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> The following program triggers division by 0 in tcp_select_window:
>
> https://gist.githubusercontent.com/dvyukov/ef28c0fd2ab57a655508ef7621b12e6c/raw/079011e2a9523a390b0621cbc1e5d9d5e637fd6d/gistfile1.txt

Yeah, tcp_disconnect() should never have existed in the first place.

We'll send a patch, unless you take care of this before us .

Thanks.
