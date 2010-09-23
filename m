From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 RFC PATCH] e1000e: NUMA changes, add Node=
 parameter
Date: Wed, 22 Sep 2010 20:36:42 -0700 (PDT)
Message-ID: <20100922.203642.02274207.davem@davemloft.net>
References: <20100923032534.11274.77976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33833
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751783Ab0IWDgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:36:23 -0400
In-Reply-To: <20100923032534.11274.77976.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:28:10 -0700

> Although a module parameter is not the preferred way for
> in-tree modules, this problem is not solvable in ethtool without
> mod params because of needing the information at probe time to
> control early allocations of memory.  Ideally there would even be
> a way to control the node where the memory of the netdev struct
> would be allocated also.

Sorry, no.

Various folks are working on infrastructure such that the Numa node of
everything other than the netdev struct can be dynamically choosen.

I'm sure we can find a way to dynamically reallocate and re-attach the
netdev structure as well.
