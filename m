From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_probe_timer() for TCP_USER_TIMEOUT
Date: Sun, 21 May 2017 13:46:33 -0400
Message-ID: <CACSApvaY+fBwG5dGM-hiYF-51vLzn2D8V-PM5JP_=Pa8hru3xw@mail.gmail.com>
References: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34310 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEURrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:47:14 -0400
Received: by mail-io0-f172.google.com with SMTP id k91so69911240ioi.1
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 10:47:14 -0700 (PDT)
In-Reply-To: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 21, 2017 at 1:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> TCP_USER_TIMEOUT is still converted to jiffies value in
> icsk_user_timeout
>
> So we need to make a conversion for the cases HZ != 1000
>
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Thank you for the fix, Eric!
