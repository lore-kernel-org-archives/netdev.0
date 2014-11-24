From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 12:20:12 -0800
Message-ID: <1416860412.17888.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
	 <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
	 <1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Josh Clark <jcinma@gmail.com>, netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:41002 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaKXUUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 15:20:15 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so3777734igb.17
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 12:20:14 -0800 (PST)
In-Reply-To: <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-24 at 11:01 -0800, Dave Taht wrote:
> On Mon, Nov 24, 2014 at 10:42 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2014-11-24 at 13:17 -0500, Josh Clark wrote:
> >
> >> But I'm seeing no change at all in qlen. qlen and backlog are both
> >> zero, which results in zero qavg, meaning I can't test the RED
> >> functionality at all.
> >
> > Wait. If you use some kernel patch without giving it, I can not comment.
> >
> > If you use regular "tc -s qdisc ...", then you'll see non zero qlen
> 
> Well, assuming you have BQL or a software rate limiter in place in
> front of it...

Hardly a matter, if you send _steady_ 12Mbit on a 10Mbit link, the
bottleneck should land on RED, BQL or not.
