From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 18:22:43 -0700 (PDT)
Message-ID: <20080706.182243.65603166.davem@davemloft.net>
References: <20080706130801.6bc36cf7@infradead.org>
	<20080706.155318.46569612.davem@davemloft.net>
	<20080706180842.36cc0b1c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757501AbYGGBWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 21:22:43 -0400
In-Reply-To: <20080706180842.36cc0b1c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 6 Jul 2008 18:08:42 -0700

> For consistency each call through ethtool_ops should
> be holding rtnl mutex. And since dev_watchdog is a timer routine,
> it is not safe to acquire a mutex there.

I think "get driver info", which does nothing but copy strings out of
the driver software state, is a safe exception to these strict locking
rules.

Don't you think? :-)

