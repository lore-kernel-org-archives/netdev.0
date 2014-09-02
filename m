From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] pktgen: add flag NO_TIMESTAMP to disable
 timestamping
Date: Mon, 01 Sep 2014 18:07:18 -0700 (PDT)
Message-ID: <20140901.180718.1517902146681973349.davem@davemloft.net>
References: <20140828161447.6652.59388.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, robert@herjulf.se
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbaIBBHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:07:19 -0400
In-Reply-To: <20140828161447.6652.59388.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 28 Aug 2014 18:14:47 +0200

> Then testing the TX limits of the stack, then it is useful to
> be-able to disable the do_gettimeofday() timetamping on every packet.
> 
> This implements a pktgen flag NO_TIMESTAMP which will disable this
> call to do_gettimeofday().
> 
> The performance change on (my system E5-2695) with skb_clone=0, goes
> from TX 2,423,751 pps to 2,567,165 pps with flag NO_TIMESTAMP. Thus,
> the cost of do_gettimeofday() or saving is approx 23 nanosec.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

This is fine, applied, thanks!
