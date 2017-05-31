From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] net: rtnetlink: bail out from rtnl_fdb_dump() on parse error
Date: Wed, 31 May 2017 17:24:00 +0200
Message-ID: <CAG_fn=WKAf6kmFqckKis0M+ZBwYrNMoXkOZKvAcYGLxD44tAgg@mail.gmail.com>
References: <20170523112028.132630-1-glider@google.com> <20170524.153224.1230164587077679673.davem@davemloft.net>
 <CAG_fn=WNnkmZ8CXqM6w7p_kmhh8Tys1HjgkfASYjvEZ2iie0hg@mail.gmail.com> <20170531.111025.1574581950547485984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:36051 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdEaPYC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:24:02 -0400
Received: by mail-vk0-f47.google.com with SMTP id p85so10215495vkd.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:24:02 -0700 (PDT)
In-Reply-To: <20170531.111025.1574581950547485984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 5:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Wed, 31 May 2017 10:56:47 +0200
>
>> Hi David,
>>
>> I've noticed that the upstream patch:
>> https://github.com/torvalds/linux/commit/0ff50e83b5122e836ca492fefb11656=
b225ac29c
>> contains the KMSAN report and the repro, despite I've put them under
>> the triple dash (IIRC Eric told me I shouldn't bloat the patch
>> descriptions with that information). Did I mess it up somehow?
>
> I put them into the main commit log message by hand when I applied the
> patch, I think the more information in commit log messages the better.

Ok, thanks for clarifying!

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
