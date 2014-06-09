From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Sun, 8 Jun 2014 22:58:20 -0700
Message-ID: <CAM_iQpVfVza0Bn6XqduZvp3zu9DA4L_4Arx20ibpJg+L-LQGtw@mail.gmail.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	<1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
	<1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>
	<1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:58669 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaFIF6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 01:58:21 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so586755obc.15
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 22:58:20 -0700 (PDT)
In-Reply-To: <1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 6:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> You did not really understood the problem.
>
> This has _nothing_ to do with dev->unreg_list
>
> Really this is all explained in the commit I gave.


I did understand it, even before sending my patch.

I just don't even like this piece of sh*t, really, we have
to rewrite it, even after you move the list_del() into the callee.
It is still as ugly as it was.
