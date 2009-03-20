From: David Miller <davem@davemloft.net>
Subject: Re: performance issue of netdev_budget and dev_weight with ixgbe
Date: Fri, 20 Mar 2009 15:59:42 -0700 (PDT)
Message-ID: <20090320.155942.87012361.davem@davemloft.net>
References: <F169D4F5E1F1974DBFAFABF47F60C10A1E6EABF2@orsmsx507.amr.corp.intel.com>
	<49C35859.7050803@baidu.com>
	<alpine.WNT.2.00.0903200835490.7220@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hanfang@baidu.com, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754535AbZCTW7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:59:55 -0400
In-Reply-To: <alpine.WNT.2.00.0903200835490.7220@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Fri, 20 Mar 2009 10:27:17 -0700 (Pacific Daylight Time)

> 64 is pretty much the global default for all drivers, not just ixgbe, we 
> didn't "pick" it at all.  at 10 Gb Ethernet speeds, we get a LOT of 
> packets.  When you play with budget you're decreasing the amount of cache 
> coherency you get by handing lots of packets at once.

You're also potentially decreasing fairness with other devices
in the system.

That's the purpose of this value, to allow preemption to other
active NAPI contexts in the current softirq processing run.
