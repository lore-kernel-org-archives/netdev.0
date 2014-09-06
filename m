From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: moved TX ring cleaning to NAPI rx poll func
Date: Fri, 05 Sep 2014 21:57:35 -0700 (PDT)
Message-ID: <20140905.215735.435013223458340103.davem@davemloft.net>
References: <1409915628-5249-1-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, software@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaIFE5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 00:57:36 -0400
In-Reply-To: <1409915628-5249-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Fri,  5 Sep 2014 13:13:48 +0200

> This patch does not affect the 10/100 GRETH MAC.
> 
> Before all GBit GRETH TX descriptor ring cleaning was done in
> start_xmit(), when descriptor list became full it activated
> TX interrupt to start the NAPI rx poll function to do TX ring
> cleaning.
> 
> With this patch the TX descriptor ring is always cleaned from
> the NAPI rx poll function, triggered via TX or RX interrupt.
> Otherwise we could end up in TX frames being sent but not
> reported to the stack being sent. On the 10/100 GRETH this
> is not an issue since the SKB is copied&aligned into private
> buffers so that the SKB can be freed directly on start_xmit()
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

Applied, thanks.
