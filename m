From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: increase fragment memory usage limits
Date: Wed, 16 Jan 2013 15:27:23 -0500 (EST)
Message-ID: <20130116.152723.2071191500595279932.davem@davemloft.net>
References: <20130115171635.23951.37626.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab3APU10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 15:27:26 -0500
In-Reply-To: <20130115171635.23951.37626.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 15 Jan 2013 18:16:35 +0100

> Increase the amount of memory usage limits for incomplete
> IP fragments.
> 
> Arguing for new thresh high/low values:
> 
>  High threshold = 4 MBytes
>  Low  threshold = 3 MBytes
 ...
> An attack could send small fragments, the smallest packet I could send
> resulted in a truesize of 896 bytes (I'm a little surprised by this).

This 896 is probably 512 for the memory block used by the driver
to back the memory, plus the sk_buff et al. overhead.

 ...
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks.
