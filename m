From: Oleg Verych <olecom@flower.upol.cz>
Subject: Re: [take22 0/4] kevent: Generic event handling mechanism.
Date: Wed, 1 Nov 2006 18:13:52 +0000 (UTC)
Message-ID: <slrnekhpbr.2j1.olecom@flower.upol.cz>
References: <1154985aa0591036@2ka.mipt.ru> <1162380963981@2ka.mipt.ru> <20061101130614.GB7195@atrey.karlin.mff.cuni.cz> <20061101132506.GA6433@2ka.mipt.ru> <20061101160551.GA2598@elf.ucw.cz> <20061101162403.GA29783@2ka.mipt.ru>
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752252AbWKASPn@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hallo, Evgeniy Polyakov.

On 2006-11-01, you wrote:
[]
>> Quantifying "how much more scalable" would be nice, as would be some
>> example where it is useful. ("It makes my webserver twice as fast on
>> monster 64-cpu box").
>
> Trivial kevent web-server can handle 3960+ req/sec on Xeon 2.4Ghz with
[...]

Seriously. I'm seeing that patches also. New, shiny, always ready "for
inclusion". But considering kernel (linux in this case) as not thing
for itself, i want to ask following question.

Where's real-life application to do configure && make && make install?

There were some comments about laking much of such programs, answers were
"was in prev. e-mail", "need to update them", something like that.
"Trivial web server" sources url, mentioned in benchmark isn't pointed
in patch advertisement. If it was, should i actually try that new
*trivial* wheel?

Saying that, i want to give you some short examples, i know.
*Linux kernel <-> userspace*:
o Alexey Kuznetsov  networking     <-> (excellent) iproute set of utilities;
o Maxim Krasnyansky tun net driver <-> vtun daemon application;

*Glibc with mister Drepper* has huge set of tests, please search for
`tst*' files in the sources.

To make a little hint to you, Evgeniy, why don't you find a little
animal in the open source zoo to implement little interface to
proposed kernel subsystem and then show it to The Big Jury (not me),
we have here? And i can not see, how you've managed to implement
something like that having almost nothing on the test basket.
Very *suspicious* ch.

One, that comes in mind is lighthttpd <http://www.lighttpd.net/>.
It had sub-interface for event systems like select,poll,epoll, when i
checked its sources last time. And it is mature, btw.

Cheers.

[ -*- OT -*-                                                           ]
[ I wouldn't write all this, unless saw your opinion about the         ]
[ reportbug (part of the Debian Bug Tracking System) this week.        ]
[ While i'm nobody here, imho, the first thing about good programmer   ]
[ must be, that he is excellent user.                                  ]
____
