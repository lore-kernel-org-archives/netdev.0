From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 31 May 2011 17:43:25 +0200
Message-ID: <0328b2351e8e11a19301262842ef0491@localhost>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net>
 <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net>
 <20110518202025.GC4175@nuttenaction>
 <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
 <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
 <BANLkTi=p1V1x+y=-cH-Q7bvueu_4_D1ywQ@mail.gmail.com>
 <BANLkTimqtjskX5q2ovTp_c05MdqBDOWsRg@mail.gmail.com>
 <da8dbb76f0cb3762227d8d0a99eaff21@localhost>
 <BANLkTikuW7VF8AUPFYHYzGe7mXp5H_emjA@mail.gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34105 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753302Ab1EaPn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 11:43:26 -0400
In-Reply-To: <BANLkTikuW7VF8AUPFYHYzGe7mXp5H_emjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 31 May 2011 08:28:18 -0700, tsuna <tsunanet@gmail.com> wrote:



> Sorry I meant a knob such as /proc/sys/net/ipv4/tcp_initrto.



That's the same! ;-)



>> The initRTO is the ideal candidate for a

>> per route knob. And happily you will solve 2) with the per route thing

>> too!

> 

> You still need a knob for the default system-wide value, don't you?



Yes, try to re-read the emails. Sysctl is a no-go, with a per route

interface you have the ability to tune the values. Talk with Jerry once

again - he wrote that at Google they already have a patch for this. And

with a per route knob you can select a even smaller value for your local

network (e.g. datacenter) and a larger value for all other routes. It makes

sense to provide a knob for this on a route basis, not on a global sysctl

basis.



But once again: talk with Jerry - he has the expert knowledge!



Hagen
