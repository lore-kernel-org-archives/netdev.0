From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 30 Jun 2006 23:16:04 +0200
Message-ID: <20060630211604.GA5302@electric-eye.fr.zoreil.com>
References: <e82qhq$4v0$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:25819 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S964891AbWGBAsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2006 20:48:02 -0400
Received: from fr.zoreil.com (electric-eye.fr.zoreil.com [213.41.134.224])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k5ULK3Be022812
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 21:20:20 GMT
To: Marcus Better <marcus@better.se>
Content-Disposition: inline
In-Reply-To: <e82qhq$4v0$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcus Better <marcus@better.se> :
> I'm seeing this problem on my Acer Travelmate 223X laptop with built-in
> Realtek 8139: The ethernet stops working, usually after at most a few
> minutes operation. The problem appears in kernel 2.6.16 and 2.6.17, but not
> in 2.6.15.

Broken again :o(

In a better world, you would narrow the suspect with a git bissect [1]
between v2.6.15 and v2.6.16.

As an alternate solution, you may try the patches available at
http://www.fr.zoreil.com/people/francois/misc/8139 against v2.6.15,
starting from 0001 and going to 0006 (of course you can revert the
patches against v2.6.16 from 0006 to 0001 too). I can't claim that
each step will compile though.

[1] http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html

-- 
Ueimor
