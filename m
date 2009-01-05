From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe select_queue broken in 2.6.28
Date: Sun, 04 Jan 2009 21:36:26 -0800 (PST)
Message-ID: <20090104.213626.253755149.davem@davemloft.net>
References: <20090101225456.68f4fe9d@extreme>
	<20090102.001933.70654029.davem@davemloft.net>
	<Pine.WNT.4.64.0901041918010.1888@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57928
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbZAEFgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 00:36:22 -0500
In-Reply-To: <Pine.WNT.4.64.0901041918010.1888@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Sun, 4 Jan 2009 19:23:20 -0800 (Pacific Standard Time)

> I understand why you want to remove this, but at the same time it is 
> something that is useful if we don't abuse it.  I know for a fact this 
> function pointer is very useful for routing performance setups, where 
> binding a Tx queue to the CPU is very useful.  Jesse actually did the work 
> on testing and getting good results with this.

This can be done generically, and in fact we have plans to make
this work.

All you want for routing is to remember the RX hash, and feed
that in (in some form) as the TX hash.
