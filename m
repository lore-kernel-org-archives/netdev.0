From: Tolga Ceylan <tolga.ceylan@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Sat, 26 Sep 2015 18:37:44 -0700
Message-ID: <CALmu+Sz0Od4d8vQeEWV1euhz6hdpLBaGhMqO7Re-om2euaNnTQ@mail.gmail.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	<1443315842.3273.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33980 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711AbbI0Bhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 21:37:45 -0400
Received: by iofb144 with SMTP id b144so145072601iof.1
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 18:37:44 -0700 (PDT)
In-Reply-To: <1443315842.3273.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 26, 2015 at 6:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> What about listen(fd, 0) ?
>
> Not sure we need to add a new socket option.
>
> It makes sense to extend reuseport logic to ignore listeners with a 0
> backlog (if not already done, I did not check)
>
>

Just checked this and no listen(fd, 0) still does schedule new
connections despite zero
accept backlog for a reuseport socket. I'll resubmit this patch with
your suggestion.
