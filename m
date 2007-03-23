From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Recent net-2.6.22 patches break bootup!
Date: Fri, 23 Mar 2007 11:07:05 -0700
Message-ID: <20070323110705.0318b80d@freekitty>
References: <20070322.120619.71102556.davem@davemloft.net>
	<20070322142753.52fec3ca@localhost>
	<20070322234704.GA521@postel.suug.ch>
	<20070322.214123.126600276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58827 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbXCWSHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 14:07:11 -0400
In-Reply-To: <20070322.214123.126600276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2007 21:41:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Thomas Graf <tgraf@suug.ch>
> Date: Fri, 23 Mar 2007 00:47:04 +0100
> 
> > * Stephen Hemminger <shemminger@linux-foundation.org> 2007-03-22 14:27
> > > Something is broken now.  If I boot the system (Fedora) it gets to:
> > > 
> > > Bringing up loopback interface:  RTNETLINK answers: Invalid argument
> > > Dump terminated
> > > RTNETLINK answers: Invalid argument
> > > ....
> > > 
> > > tg3 device eth0 does not seem to be present, delaying initialization
> > > 
> > > 
> > > then it hangs because cups won't come up without loopback
> > 
> > Thinko. It always returned the first message handler of a rtnl
> > family.
> > 
> > [RTNL]: Properly return rntl message handler
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Applied, thanks Thomas.

Thanks, that fixes it

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
