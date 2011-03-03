From: David Miller <davem@davemloft.net>
Subject: Re: bonding...
Date: Thu, 03 Mar 2011 12:30:32 -0800 (PST)
Message-ID: <20110303.123032.15242274.davem@davemloft.net>
References: <20110303114539.GB5146@hmsreliant.think-freely.org>
	<20110303160404.GO11864@gospo.rdu.redhat.com>
	<6286.1299173065@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36122
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932248Ab1CCU3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:29:55 -0500
In-Reply-To: <6286.1299173065@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 03 Mar 2011 09:24:25 -0800

> 	My main problem keeping up at the moment is another demand on my
> time that should run its course in a couple of weeks.  My time for
> community activity is somewhat limited until then.

Someone needs to exist who can keep things going when you are too
busy.  Unless you're like me and never take a day off, you need
at least one co-maintainer if your subsystem has lots of daily
activity as bonding now does.

> 	I personally like Stephen's suggestion to hook bonding into a
> netfilter gadget, similar to ebtables for bridge.  Done properly, such a
> gadget should handle (or be extended to handle) the niche cases that
> right now end up as new knobs in the driver.

Netfilter has a JIT like matching engine coming soon, that could
be made generic and plugged into.
