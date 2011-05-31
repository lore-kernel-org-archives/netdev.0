From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 31 May 2011 08:28:18 -0700
Message-ID: <BANLkTikuW7VF8AUPFYHYzGe7mXp5H_emjA@mail.gmail.com>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net> <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net> <20110518202025.GC4175@nuttenaction>
 <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com> <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
 <BANLkTi=p1V1x+y=-cH-Q7bvueu_4_D1ywQ@mail.gmail.com> <BANLkTimqtjskX5q2ovTp_c05MdqBDOWsRg@mail.gmail.com>
 <da8dbb76f0cb3762227d8d0a99eaff21@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <da8dbb76f0cb3762227d8d0a99eaff21@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2011 at 8:25 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> Skip sysctl, it is deprecated.

Sorry I meant a knob such as /proc/sys/net/ipv4/tcp_initrto.

> The initRTO is the ideal candidate for a
> per route knob. And happily you will solve 2) with the per route thing too!

You still need a knob for the default system-wide value, don't you?

-- 
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
