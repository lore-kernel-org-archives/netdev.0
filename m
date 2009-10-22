From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Thu, 22 Oct 2009 03:56:01 -0700 (PDT)
Message-ID: <20091022.035601.193700201.davem@davemloft.net>
References: <20091021022713.32449.54868.stgit@localhost.localdomain>
	<20091021.215031.57955781.davem@davemloft.net>
	<1256199756.2634.65.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, gospo@redhat.com,
	netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754849AbZJVKzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 06:55:38 -0400
In-Reply-To: <1256199756.2634.65.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 22 Oct 2009 01:22:36 -0700

> The first thing any performance guide says is to disable irqbalance

Such guides are wrong, and that's the end of this discussion.

These kinds of guides also say to do all kinds of crazy things with
the socket sysctl settings.  That's wrong too and we absolutely do not
do things to accomodate nor support those guide suggestions.

And we won't do that here.

I'm especially not going to succumb in this case because Arjan has
been more than responsive to making sure irqbalanced in userspace does
the right thing for networking devices, even multiqueue ones.

So we can make it do the right thing when flow director is present.
In fact, the thing you want for flow director makes sense in the
general case too.
