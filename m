From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: gred: add TCA_GRED_LIMIT attribute
Date: Tue, 12 May 2015 18:23:11 -0400 (EDT)
Message-ID: <20150512.182311.1437113579733139908.davem@davemloft.net>
References: <1431223307-26669-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933666AbbELWXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 18:23:12 -0400
In-Reply-To: <1431223307-26669-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sat,  9 May 2015 22:01:46 -0400

> In a GRED qdisc, if the default "virtual queue" (VQ) does not have drop
> parameters configured, then packets for the default VQ are not subjected
> to RED and are only dropped if the queue is larger than the net_device's
> tx_queue_len. This behavior is useful for WRED mode, since these packets
> will still influence the calculated average queue length and (therefore)
> the drop probability for all of the other VQs. However, for some drivers
> tx_queue_len is zero. In other cases the user may wish to make the limit
> the same for all VQs (including the default VQ with no drop parameters).
> 
> This change adds a TCA_GRED_LIMIT attribute to set the GRED queue limit,
> in bytes, during qdisc setup. (This limit is in bytes to be consistent
> with the drop parameters.) The default limit is the same as for a bfifo
> queue (tx_queue_len * psched_mtu). If the drop parameters of any VQ are
> configured with a smaller limit than the GRED queue limit, that VQ will
> still observe the smaller limit instead.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied, thanks David.
