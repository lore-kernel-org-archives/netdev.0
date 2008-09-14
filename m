From: David Miller <davem@davemloft.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Sun, 14 Sep 2008 16:56:55 -0700 (PDT)
Message-ID: <20080914.165655.193720725.davem@davemloft.net>
References: <20080821120409.GA2226@x200.localdomain>
	<20080821.050857.131314665.davem@davemloft.net>
	<20080914142654.3114cb3a@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, csnook@redhat.com, netdev@vger.kernel.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51316
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753375AbYINX5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 19:57:01 -0400
In-Reply-To: <20080914142654.3114cb3a@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Sun, 14 Sep 2008 14:26:54 -0500

> Should a netdev driver be coded such that a watchdog transmit timeout
> never occurs?
> 
> [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> 
> Or is a watchdog timeout an expected occurrence if a cable is
> unplugged/plugged?

If the cable is unplugged, netif_carrier_off() will be (or should
be) invoked by the driver, and that cancels the watchdog timer.

This is all from memory since I'm travelling and don't have the
time to check this directly.  You should investigate this yourself
instead of asking me if you want a truly definitive answer :)
