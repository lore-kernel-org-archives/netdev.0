From: Josh Clark <jcinma@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 14:14:12 -0500
Message-ID: <CAHmvzZTF76DwdyBF9og2v9Vumx5v0BhHR584uX54o5R+T+iUMw@mail.gmail.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
 <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
 <1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com> <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:57029 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbaKXTOy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 14:14:54 -0500
Received: by mail-wg0-f54.google.com with SMTP id l2so2671236wgh.13
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 11:14:52 -0800 (PST)
In-Reply-To: <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 2:01 PM, Dave Taht <dave.taht@gmail.com> wrote:
> On Mon, Nov 24, 2014 at 10:42 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> On Mon, 2014-11-24 at 13:17 -0500, Josh Clark wrote:
>>
>>> But I'm seeing no change at all in qlen. qlen and backlog are both
>>> zero, which results in zero qavg, meaning I can't test the RED
>>> functionality at all.
>>
>> Wait. If you use some kernel patch without giving it, I can not comm=
ent.
>>
>> If you use regular "tc -s qdisc ...", then you'll see non zero qlen
>
> Well, assuming you have BQL or a software rate limiter in place in
> front of it...
>
At the moment, I'm using standard RED (from /net/sched/sch_red.c) with
some printks to output qstats.
Are you saying that when I set this up, I need to use the -s flag in
tc to maintain those statistics?

One more question: if I don't use -s, then what would RED use to calcul=
ate qavg?

>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Dave T=C3=A4ht
>
> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
