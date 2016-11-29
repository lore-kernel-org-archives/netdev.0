From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Mon, 28 Nov 2016 22:57:38 -0800
Message-ID: <CAM_iQpXqv7MvcTwCgsbgpK30xra9kjnTbcJu8nT0QuMh_ZFz7Q@mail.gmail.com>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com> <583B9D22.8090906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32951 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932912AbcK2G6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:58:05 -0500
Received: by mail-io0-f169.google.com with SMTP id j65so274640520iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:58:04 -0800 (PST)
In-Reply-To: <583B9D22.8090906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 6:57 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> Hi Cong,
>
> Thanks a lot for doing this. Can you rebase it on top of Daniel's patch
> though,
>
>  [PATCH net] net, sched: respect rcu grace period on cls destruction
>
> And then push the NULL pointer work for the cls_fw and cls_route
> classifiers into another patch.
>
> Then I believe the last thing to make this correct is to convert the
> call_rcu() paths to call_rcu_bh().

Sure, will rebase my patch once DaveM merges net into net-next.

Thanks.
