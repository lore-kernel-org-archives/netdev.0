From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Mon, 28 Nov 2016 22:59:34 -0800
Message-ID: <CAM_iQpVFGU2aRY=4CqqQSWPVftMVEKDj2SVEtSARJabW3wjMkg@mail.gmail.com>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
 <5836A4D4.2010500@mellanox.com> <5836BD82.6080407@iogearbox.net>
 <5836C87E.8050506@mellanox.com> <58370558.9070004@iogearbox.net>
 <CAM_iQpVxevmk3rgsnALC0JCqx7pOF2OBc=kpg9QDK8Cwb6P9Zw@mail.gmail.com>
 <58396D71.8070703@iogearbox.net> <583A29E3.8030809@iogearbox.net>
 <583A6567.30003@mellanox.com> <583A7D67.50003@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33041 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755989AbcK2G74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:59:56 -0500
Received: by mail-io0-f176.google.com with SMTP id j65so274698408iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:59:55 -0800 (PST)
In-Reply-To: <583A7D67.50003@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2016 at 10:29 PM, Roi Dayan <roid@mellanox.com> wrote:
> Hi,
>
> I tested "[PATCH net] net, sched: respect rcu grace period on cls
> destruction" and could not reproduce my original issue.
> I rebased "[Patch net-next] net_sched: move the empty tp check from
> ->destroy() to ->delete()" over to test it in the same tree and got into a
> new trace in fl_delete.

I will take care of this when I rebase my patch.

Thanks for testing anyway.
