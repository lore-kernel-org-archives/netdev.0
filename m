From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support, replayed.
Date: Thu, 05 Apr 2007 14:35:27 -0700 (PDT)
Message-ID: <20070405.143527.63129672.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC329029ADBC2@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeb.j.cramer@intel.com, christopher.leech@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, auke-jan.h.kok@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767339AbXDEVf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:35:28 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029ADBC2@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 5 Apr 2007 14:33:19 -0700

> David,
> 	Please consider pulling from my git tree:
> 
> 	git-pull git://lost.foo-projects.org/~ppwaskie/git/net-2.6.22
> multiqueue
> 
> This is a branch named 'multiqueue' of a recent pull from your tree with
> an updated implementation of the multiqueue implementation we've been
> working on.  Included in this is:
> 
> 1) A simplified API where all drivers will allocate a queue struct for
> each queue on the NIC.
> 2) A transparent stack change for both non-mq and mq devices to use the
> same codepath.
> 3) Remove the per-queue locking model, and just use the per-queue
> netif_{start|stop|wake}_subqueue() functions for multiqueue management.
> 4) Updated multiqueue documentation in Documentation/networking
> describing the implementation and base driver requirements to implement
> multiqueue support.

Thanks for following up on this work, but it really needs to be
reviewed here on netdev, I really can't just pull this into my
tree until it is reviewed properly here.

So, please post the new feature as a set of patches.

Thanks a lot.
