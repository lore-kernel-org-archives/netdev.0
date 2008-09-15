From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Sun, 14 Sep 2008 19:11:35 -0500
Message-ID: <20080914191135.2a28e6a6@osprey.hogchain.net>
References: <20080821120409.GA2226@x200.localdomain>
	<20080821.050857.131314665.davem@davemloft.net>
	<20080914142654.3114cb3a@osprey.hogchain.net>
	<20080914.165655.193720725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, csnook@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:48752 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413AbYIOALi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 20:11:38 -0400
In-Reply-To: <20080914.165655.193720725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Sep 2008 16:56:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Sun, 14 Sep 2008 14:26:54 -0500
> 
> > Should a netdev driver be coded such that a watchdog transmit
> > timeout never occurs?
> > 
> > [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> > 
> > Or is a watchdog timeout an expected occurrence if a cable is
> > unplugged/plugged?
> 
> If the cable is unplugged, netif_carrier_off() will be (or should
> be) invoked by the driver, and that cancels the watchdog timer.

Thanks, I think I found the problem.  It seems to fix it for me, but
I'd like Alexey to test the patch before I submit it to mainline.  He
seems to be able to hit the issue more frequently than I can.

> 
> This is all from memory since I'm travelling and don't have the
> time to check this directly.  You should investigate this yourself
> instead of asking me if you want a truly definitive answer :)

I've been investigating it myself in my spare time since Alexey pointed
out the problem August 21.

Happy travels.
