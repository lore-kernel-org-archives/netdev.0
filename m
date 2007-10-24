From: David Miller <davem@davemloft.net>
Subject: Re: on the topic of alternate MAC addresses
Date: Tue, 23 Oct 2007 20:22:10 -0700 (PDT)
Message-ID: <20071023.202210.74747025.davem@davemloft.net>
References: <20071023.180534.59659315.davem@davemloft.net>
	<471EAD01.5030502@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752662AbXJXDW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:22:26 -0400
In-Reply-To: <471EAD01.5030502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Oct 2007 22:25:05 -0400

> hmmmm.  Using ethtool isn't a big deal, but IMO you probably want more 
> than just an exported list for the usage you described...  it sounds 
> like some sort of reservation system should be used, to note which MAC 
> addresses are [not] in use?
> 
> Then a virt client -- or anyone who wants multiple unicast addresses for 
> whatever reason -- can let other clients to avoid MAC addresses 1, 7, or 
> 13 (random examples).

I see your point.

However, it's not the virt clients that do this, it's the control
node (aka: domain 0) which has to manage these things.

It has to manage all of the global hardware resources and allocate
them out to itself and the clients anyways.

And this is why I think it's sufficient to just publish the list of
MAC addresses from the driver, and leave the allocation and policy
to the userland virtualizatin daemon running on the control node.

Let me know if you still disagree.
