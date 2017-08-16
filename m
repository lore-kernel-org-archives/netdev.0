From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH 1/2] tcp: Remove unnecessary dst check in tcp_conn_request.
Date: Wed, 16 Aug 2017 23:32:51 +0800
Message-ID: <CAMDZJNVgMH06reFphOMyRU7Xrba9i=ezR40wWLuqyYWgZmd08Q@mail.gmail.com>
References: <1502890265-9285-1-git-send-email-xiangxia.m.yue@gmail.com> <1502894687.4936.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34537 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdHPP7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:59:44 -0400
Received: by mail-oi0-f43.google.com with SMTP id x3so40414604oia.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:59:44 -0700 (PDT)
In-Reply-To: <1502894687.4936.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 10:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-08-16 at 06:31 -0700, Tonghao Zhang wrote:
>> Because we remove the tcp_tw_recycle support in the commit
>
>
>> 4396e46187c ('tcp: remove tcp_tw_recycle') and also delete
>> the code 'af_ops->route_req' for sysctl_tw_recycle in tcp_conn_request.
>> Now when we call the 'af_ops->route_req', the dist always is
>> NULL, and we remove the unnecessay check.
>
> Thanks for these patches.
>
> You forgot :
>
> 1) a cover letter ( [PATCH next-next 0/2] tcp: ....
>
> 2) clearly state which tree you are targeting
> ( read Documentation/networking/netdev-FAQ.txt )
Thanks, I do this in v2

> 3) Also, I would also have removed tcp_peer_is_proven()
> since it is also called with dst=NULL
Thanks for your work.

>
>
