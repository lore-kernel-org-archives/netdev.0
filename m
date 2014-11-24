From: Dave Taht <dave.taht@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 11:01:53 -0800
Message-ID: <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
	<1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
	<1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Clark <jcinma@gmail.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:48506 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbaKXTBx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 14:01:53 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so7562408obc.39
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 11:01:53 -0800 (PST)
In-Reply-To: <1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 10:42 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Mon, 2014-11-24 at 13:17 -0500, Josh Clark wrote:
>
>> But I'm seeing no change at all in qlen. qlen and backlog are both
>> zero, which results in zero qavg, meaning I can't test the RED
>> functionality at all.
>
> Wait. If you use some kernel patch without giving it, I can not comme=
nt.
>
> If you use regular "tc -s qdisc ...", then you'll see non zero qlen

Well, assuming you have BQL or a software rate limiter in place in
front of it...


>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
