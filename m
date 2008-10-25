From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 00:19:40 -0700 (PDT)
Message-ID: <20081025.001940.251852864.davem@davemloft.net>
References: <1224905848.5161.27.camel@marge.simson.net>
	<20081024.221653.23695396.davem@davemloft.net>
	<1224914333.3822.18.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: efault@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751581AbYJYHUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 03:20:02 -0400
In-Reply-To: <1224914333.3822.18.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Galbraith <efault@gmx.de>
Date: Sat, 25 Oct 2008 07:58:53 +0200

> I spent long day manweeks trying to bisect and whatnot.  It's immune to
> my feeble efforts, and my git-foo.

I understand, this is what happened to me when I tried to look into
the gradual tbench regressions since 2.6.22

I guess the only way to attack these things is to analyze the code and
make some debugging hacks to get some measurements and numbers.
