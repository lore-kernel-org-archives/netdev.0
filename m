From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 07:53:05 +0200
Message-ID: <1224913985.3822.12.camel@marge.simson.net>
References: <200810250025.35734.rjw@sisk.pl>
	 <20081024.163111.244324800.davem@davemloft.net>
	 <1224907501.5161.36.camel@marge.simson.net>
	 <20081024.221525.259940836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:60559 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751222AbYJYFxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 01:53:10 -0400
In-Reply-To: <20081024.221525.259940836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-24 at 22:15 -0700, David Miller wrote:
> From: Mike Galbraith <efault@gmx.de>
> Date: Sat, 25 Oct 2008 06:05:01 +0200
> 
> > My test data indicates (to me anyway) that there is another source of
> > localhost throughput loss in .27.  In that data, there is no hrtick
> > overhead since I didn't have highres timers enabled, and computational
> > costs added in .27 were removed.  Dunno where it lives, but it does
> > appear to exist.
> 
> Disabling TSO on loopback doesn't fix that bit for you?

No.  Those numbers are with TSO/GSO disabled.

I did a manual 100% sched and everything related revert to 26 scheduler,
and had ~the same result as these numbers.  27 with 100% revert actually
performed a bit _worse_ for me than 27 with it's overhead.. which
puzzles me greatly.

	-Mike

