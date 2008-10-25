From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 24 Oct 2008 22:16:53 -0700 (PDT)
Message-ID: <20081024.221653.23695396.davem@davemloft.net>
References: <20081010115725.GD19487@elte.hu>
	<200810250025.35734.rjw@sisk.pl>
	<1224905848.5161.27.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: efault@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbYJYFRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 01:17:15 -0400
In-Reply-To: <1224905848.5161.27.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Galbraith <efault@gmx.de>
Date: Sat, 25 Oct 2008 05:37:28 +0200

> Part of the .27 regression was added scheduler overhead going from .26
> to .27.  The scheduler overhead is now gone, but an unidentified source
> of localhost throughput loss remains for both SMP and UP configs.

It has to be the TSO thinky Evgeniy hit too right?

If not, please bisect this.
