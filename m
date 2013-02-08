From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/10] igb: Update igb to use a path similar to
 ixgbe to determine when to stop Tx
Date: Fri, 08 Feb 2013 14:18:54 -0500 (EST)
Message-ID: <20130208.141854.2122874496462368419.davem@davemloft.net>
References: <1360319958-10497-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<1360326369.28557.95.camel@edumazet-glaptop>
	<511531AE.8030807@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946826Ab3BHTS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:18:56 -0500
In-Reply-To: <511531AE.8030807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 08 Feb 2013 09:11:10 -0800

> For igb the IGB_MAX_DATA_PER_TXD is 32K as well.  So if I am not
> mistaken we should be fine.  The only time we risk exceeding that is
> if we have 64K page size.  It sounds like we may need to work in the
> ixgbe driver though since I believe the limit for it is only 16K per
> descriptor.
> 
> I will also submit an update for this patch that replaces PAGE_SIZE
> with NETDEV_FRAG_PAGE_MAX_SIZE in order to keep the two in sync.

I therefore expect a respin of this series from Jeff once the
update of this patch is resolved.

Thanks.
