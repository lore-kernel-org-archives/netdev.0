From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Wed, 18 Jan 2017 21:22:53 -0800
Message-ID: <CALx6S36p2g8EP48R+nWQu9tHtS5h8eKo7bj7rskmSMxCU36KXA@mail.gmail.com>
References: <20170113.121407.448230751444957957.davem@davemloft.net>
 <CALzJLG_fjiGyuB_buZqOSMU7SaCnuqFiZ0UyW+hPDq+3yx7TWg@mail.gmail.com>
 <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w@mail.gmail.com> <20170118.123207.53777509111948450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Leon Romanovsky <leon@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36643 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752041AbdASFYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 00:24:00 -0500
Received: by mail-qt0-f195.google.com with SMTP id l7so6523325qtd.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 21:22:54 -0800 (PST)
In-Reply-To: <20170118.123207.53777509111948450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 9:32 AM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Mon, 16 Jan 2017 22:30:29 +0200
>
>>> But please bear with me here, what if we queue this patch up to -stable ?
>
> You've got to be seriously kidding me that your idea is to submit an
> incredibly diruptive driver rename to -stable to solve this problem.
>
> That is completely a non-starter.
>
> The whole idea is to _MINIMIZE_ the amount of change happening in
> -stable in order to avoid regressions and negative consequence for
> everyone using the -stable tree.
>
> I am strongly against a major reorganization of this driver, sorry.
> The Synopsys folks want to do the same thing for the stmmac driver,
> for even more nefarious reasons, and I'm rejecting all of their
> attempts to do that as well.
>
> If you look in that thread, they said they would "help" with the
> -stable backports, and in there I explained why that is a completely
> empty gesture.  There are people doing the backports outside of your
> spehere of influence, who need to get their work done "right now" and
> aren't going to consult you and be on your schedule for doing those
> backports.

David,

In principle I  agree, but as I previously wrote backporting this
driver is already a bear. We need to do something here as this is
quickly approaching being infeasible to backport. Even if we don't
restructure the directories I'd still like to see some effort towards
feature modularization and isolation.

Tom
