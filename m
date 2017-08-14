From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Mon, 14 Aug 2017 14:15:58 -0700
Message-ID: <CAM_iQpX2=Fg8JN1c8qnLPae34hsYEG7xUKZ-RoppBnVoBDb+6g@mail.gmail.com>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
 <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru> <CAM_iQpUJRAn75aBrBzoWABt21tgTYLo1MPNQwTUa9BSs0QXyaQ@mail.gmail.com>
 <7267faab-c089-e60b-0696-3734f801c1ba@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34092 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbdHNVQT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 17:16:19 -0400
Received: by mail-pg0-f47.google.com with SMTP id u185so54567952pgb.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 14:16:19 -0700 (PDT)
In-Reply-To: <7267faab-c089-e60b-0696-3734f801c1ba@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 5:59 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
> This should work, I suppose.
>
> But this approach requires careful review for all qdisc, mine is completely
> mechanical.

Well, we don't have many classful qdisc's. Your patch actually
touches more qdisc's than mine, because you change an API, so
it is slightly harder to backport. ;)
