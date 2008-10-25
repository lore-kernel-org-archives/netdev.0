From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 24 Oct 2008 22:15:25 -0700 (PDT)
Message-ID: <20081024.221525.259940836.davem@davemloft.net>
References: <200810250025.35734.rjw@sisk.pl>
	<20081024.163111.244324800.davem@davemloft.net>
	<1224907501.5161.36.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: efault@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbYJYFPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 01:15:48 -0400
In-Reply-To: <1224907501.5161.36.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Galbraith <efault@gmx.de>
Date: Sat, 25 Oct 2008 06:05:01 +0200

> My test data indicates (to me anyway) that there is another source of
> localhost throughput loss in .27.  In that data, there is no hrtick
> overhead since I didn't have highres timers enabled, and computational
> costs added in .27 were removed.  Dunno where it lives, but it does
> appear to exist.

Disabling TSO on loopback doesn't fix that bit for you?

