From: David Miller <davem@davemloft.net>
Subject: Re: virtio-net: put virtio net header inline with data
Date: Sat, 27 Jul 2013 20:06:40 -0700 (PDT)
Message-ID: <20130727.200640.2184866925272160039.davem@davemloft.net>
References: <87ppu78nu8.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab3G1DGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 23:06:41 -0400
In-Reply-To: <87ppu78nu8.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 25 Jul 2013 10:20:23 +0930

> From: Michael S. Tsirkin <mst@redhat.com>
> 
> For small packets we can simplify xmit processing
> by linearizing buffers with the header:
> most packets seem to have enough head room
> we can use for this purpose.
> Since existing hypervisors require that header
> is the first s/g element, we need a feature bit
> for this.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied to net-next, thanks.
