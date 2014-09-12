From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] sunvnet: Avoid sending superfluous LDC
 messages.
Date: Fri, 12 Sep 2014 18:19:25 -0400 (EDT)
Message-ID: <20140912.181925.2227644293597000085.davem@davemloft.net>
References: <20140911135722.GA22398@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org,
	bob.picco@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbaILWT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 18:19:27 -0400
In-Reply-To: <20140911135722.GA22398@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 11 Sep 2014 09:57:22 -0400

> When sending out a burst of packets across multiple descriptors,
> it is sufficient to send one LDC "start" trigger for
> the first descriptor, so do not send an LDC "start" for every
> pass through vnet_start_xmit. Similarly, it is sufficient to send
> one "DRING_STOPPED" trigger for the last dring (and if that
> fails, hold off and send the trigger later).
> 
> Optimizations to the number of LDC messages helps avoid
> filling up the LDC channel with superfluous LDC messages
> that risk triggering flow-control on the channel,
> and also boosts performance.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

Applied, thanks.
