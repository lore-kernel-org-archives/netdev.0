From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_probe_timer() for TCP_USER_TIMEOUT
Date: Sun, 21 May 2017 11:01:28 -0700
Message-ID: <1495389688.6465.54.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACSApvaY+fBwG5dGM-hiYF-51vLzn2D8V-PM5JP_=Pa8hru3xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36383 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753488AbdEUSBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 14:01:30 -0400
Received: by mail-pg0-f67.google.com with SMTP id h64so15158431pge.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 11:01:30 -0700 (PDT)
In-Reply-To: <CACSApvaY+fBwG5dGM-hiYF-51vLzn2D8V-PM5JP_=Pa8hru3xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-05-21 at 13:46 -0400, Soheil Hassas Yeganeh wrote:
> On Sun, May 21, 2017 at 1:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > TCP_USER_TIMEOUT is still converted to jiffies value in
> > icsk_user_timeout
> >
> > So we need to make a conversion for the cases HZ != 1000
> >
> > Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Thank you for the fix, Eric!

Thanks for reviewing !
