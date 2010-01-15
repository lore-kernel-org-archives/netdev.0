From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 15 Jan 2010 01:06:28 -0800 (PST)
Message-ID: <20100115.010628.67106329.davem@davemloft.net>
References: <F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
	<20100115.004456.15627093.davem@davemloft.net>
	<1263546020.2038.7.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932094Ab0AOJGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:06:19 -0500
In-Reply-To: <1263546020.2038.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 15 Jan 2010 01:00:20 -0800

> What I've been thinking of is more for the NUMA allocations per port.
> If we have, say 2 sockets, 8 cores a piece, then we have 16 CPUs.  If we
> assign a port to socket 0, I think the best use of resources is to
> allocate 8 Rx/Tx queues, one per core in that socket.  If an application
> comes from the other socket, we can have a table to map the other 8
> cores from that socket into the 8 queues, instead of piling them all
> into one of the Tx queues.

I fail to see how this can act substantially better than simply
feeding traffic evenly amongst whatever group of queues have
been configured.
