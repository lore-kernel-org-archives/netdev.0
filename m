From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 31 May 2011 17:25:22 +0200
Message-ID: <da8dbb76f0cb3762227d8d0a99eaff21@localhost>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net>
 <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net>
 <20110518202025.GC4175@nuttenaction>
 <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
 <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
 <BANLkTi=p1V1x+y=-cH-Q7bvueu_4_D1ywQ@mail.gmail.com>
 <BANLkTimqtjskX5q2ovTp_c05MdqBDOWsRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	David Miller <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTimqtjskX5q2ovTp_c05MdqBDOWsRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 31 May 2011 07:48:09 -0700, tsuna <tsunanet@gmail.com> wrote:



> I talked to Jerry and he's agreed to share some patches that Google

> has been using internally for years.



Great!



> Personally what I think would be ideal would be:

>   1. A sysctl knob for initRTO, to allow people to adjust this

> appropriately for their environment.

>   2. Apply the srtt / rttvar seen on previous connections to new

>   connections.

> 

> Does that sound reasonable?

> 

> For 2), I'm not sure how the details would work yet, I believe the

> kernel already has what's necessary to remember these things on a per

> peer basis, but it would be nice if I could specify things like "for

> 10.x.0.0/16 (local datacenter) use this aggressive setting, for

> 10.0.0.0/8 (my internal backend network) use that, for everything else

> (Internets etc.) use the default".



Skip sysctl, it is deprecated. The initRTO is the ideal candidate for a

per route knob. And happily you will solve 2) with the per route thing too!

;-)



Search the web, you will find some patches where you can see how to extend

the per route system - including iproute2.



Hagen

   
