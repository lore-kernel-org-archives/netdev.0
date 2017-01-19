From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Thu, 19 Jan 2017 00:38:32 -0500 (EST)
Message-ID: <20170119.003832.1262212358977773325.davem@davemloft.net>
References: <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w@mail.gmail.com>
        <20170118.123207.53777509111948450.davem@davemloft.net>
        <CALx6S36p2g8EP48R+nWQu9tHtS5h8eKo7bj7rskmSMxCU36KXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@dev.mellanox.co.il, saeedm@mellanox.com,
        dledford@redhat.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, leon@kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbdASFig (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 00:38:36 -0500
In-Reply-To: <CALx6S36p2g8EP48R+nWQu9tHtS5h8eKo7bj7rskmSMxCU36KXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 18 Jan 2017 21:22:53 -0800

> In principle I  agree, but as I previously wrote backporting this
> driver is already a bear. We need to do something here as this is
> quickly approaching being infeasible to backport. Even if we don't
> restructure the directories I'd still like to see some effort towards
> feature modularization and isolation.

There simply is a lot changing all the time, no restructuring is going
to reduce that.  The driver simply gets a lot of churn.

Backporting such things through a bunch of file and/or directory
renames is seriously nothing but asking for more punishment.

That's why I am against it.
