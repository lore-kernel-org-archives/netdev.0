From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Fri, 20 May 2011 13:00:02 +0200
Message-ID: <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net>
 <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net>
 <20110518202025.GC4175@nuttenaction>
 <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <tsunanet@gmail.com>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 20 May 2011 03:27:37 -0700, "H.K. Jerry Chu" wrote:



Hi Jerry



> Not sure how our various parameter tuning proposals deviate from the

"TCP

> over everything" principle?



For our environment it hurts because we _always_ have an initial RTO >1. I

understand and accept that 98% will benefit of this modification, no doubt

Jerry! Try to put yourself in our situation: imaging a proposal of an init

RTO modification to 0.5 seconds. Maybe because 98% of Internet traffic is

now localized and the RTO is average now 0.2 seconds. Anyway, this will

penalize your network always and this will be the situation for one of my

customer. I can live with that, I see the benefits for the rest of the

world. But I am happy to see a knob where I can restore the old behavior.

Maybe some other environments will benefit from a even lower or higher

initial RTO.



Hagen
