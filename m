From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 07:58:53 +0200
Message-ID: <1224914333.3822.18.camel@marge.simson.net>
References: <20081010115725.GD19487@elte.hu>
	 <200810250025.35734.rjw@sisk.pl>
	 <1224905848.5161.27.camel@marge.simson.net>
	 <20081024.221653.23695396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35324 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751180AbYJYF65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 01:58:57 -0400
In-Reply-To: <20081024.221653.23695396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-24 at 22:16 -0700, David Miller wrote:
> From: Mike Galbraith <efault@gmx.de>
> Date: Sat, 25 Oct 2008 05:37:28 +0200
> 
> > Part of the .27 regression was added scheduler overhead going from .26
> > to .27.  The scheduler overhead is now gone, but an unidentified source
> > of localhost throughput loss remains for both SMP and UP configs.
> 
> It has to be the TSO thinky Evgeniy hit too right?

Dunno.

> If not, please bisect this.

(oh my <fword> gawd:)

I spent long day manweeks trying to bisect and whatnot.  It's immune to
my feeble efforts, and my git-foo.

	-Mike

