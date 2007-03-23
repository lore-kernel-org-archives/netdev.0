From: David Miller <davem@davemloft.net>
Subject: Re: Recent net-2.6.22 patches break bootup!
Date: Thu, 22 Mar 2007 21:41:23 -0700 (PDT)
Message-ID: <20070322.214123.126600276.davem@davemloft.net>
References: <20070322.120619.71102556.davem@davemloft.net>
	<20070322142753.52fec3ca@localhost>
	<20070322234704.GA521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933618AbXCWElY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 00:41:24 -0400
In-Reply-To: <20070322234704.GA521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 23 Mar 2007 00:47:04 +0100

> * Stephen Hemminger <shemminger@linux-foundation.org> 2007-03-22 14:27
> > Something is broken now.  If I boot the system (Fedora) it gets to:
> > 
> > Bringing up loopback interface:  RTNETLINK answers: Invalid argument
> > Dump terminated
> > RTNETLINK answers: Invalid argument
> > ....
> > 
> > tg3 device eth0 does not seem to be present, delaying initialization
> > 
> > 
> > then it hangs because cups won't come up without loopback
> 
> Thinko. It always returned the first message handler of a rtnl
> family.
> 
> [RTNL]: Properly return rntl message handler
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
