From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Tue, 05 May 2009 11:58:19 -0700 (PDT)
Message-ID: <20090505.115819.84151021.davem@davemloft.net>
References: <1241435206.8115.104.camel@localhost.localdomain>
	<9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawk@comx.dk, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753230AbZEES6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 14:58:24 -0400
In-Reply-To: <9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 5 May 2009 11:47:09 -0700

> NAK.  RNBC is not a counter for buffer overruns, and so should not be
> counted as such.

I'd say technically it is, it indicates that more packets arrived than
the available receive buffers could handle.

If anything, this is the closest this device has for this kind of
situation, and it's useful for diagnosing problems.
