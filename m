From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: simple_tx_hash shouldn't hash inside fragments
Date: Sat, 20 Sep 2008 22:06:24 -0700 (PDT)
Message-ID: <20080920.220624.177591478.davem@davemloft.net>
References: <20080919004337.10035.3409.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbYIUFGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 01:06:36 -0400
In-Reply-To: <20080919004337.10035.3409.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 18 Sep 2008 17:43:37 -0700

> Currently simple_tx_hash is hashing inside of udp fragments.  As a result
> packets are getting getting sent to all queues when they shouldn't be.
> This causes a serious performance regression which can be seen by sending
> UDP frames larger than mtu on multiqueue devices.  This change will make
> it so that fragments are hashed only as IP datagrams w/o any protocol
> information.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

As we discussed on IRC this fixes a pretty serious performance regression
compared to previous releases, so I added this to net-2.6 and will push
to Linus.

Thanks!
