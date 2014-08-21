From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Allow setting multicast filter on all macvlan
 types
Date: Thu, 21 Aug 2014 16:54:53 -0700 (PDT)
Message-ID: <20140821.165453.2108983276232183602.davem@davemloft.net>
References: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com, mst@redhat.com,
	jasowang@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaHUXyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:54:54 -0400
In-Reply-To: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevic@redhat.com>
Date: Fri, 15 Aug 2014 13:04:59 -0400

> Currently, macvlan code restricts multicast and unicast
> filter setting only to passthru devices.  As a result,
> if a guest using macvtap wants to receive multicast
> traffic, it has to set IFF_ALLMULTI or IFF_PROMISC.
> 
> This patch makes it possible to use the fdb interface
> to add multicast addresses to the filter thus allowing
> a guest to receive only targeted multicast traffic.
> 
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
