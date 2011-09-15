From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net 1/2] Revert "sfc: Use write-combining to reduce TX
 latency" and follow-ups
Date: Thu, 15 Sep 2011 17:25:38 -0400 (EDT)
Message-ID: <20110915.172538.47479446951531800.davem@redhat.com>
References: <1314914969.2733.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934922Ab1IOVZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 17:25:41 -0400
In-Reply-To: <1314914969.2733.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 01 Sep 2011 23:09:29 +0100

> This reverts commits 65f0b417dee94f779ce9b77102b7d73c93723b39,
> d88d6b05fee3cc78e5b0273eb58c31201dcc6b76,
> fcfa060468a4edcf776f0c1211d826d5de1668c1,
> 747df2258b1b9a2e25929ef496262c339c380009 and
> 867955f5682f7157fdafe8670804b9f8ea077bc7.
> 
> Depending on the processor model, write-combining may result in
> reordering that the NIC will not tolerate.  This typically results
> in a DMA error event and reset by the driver, logged as:
> 
> sfc 0000:0e:00.0: eth2: TX DMA Q reports TX_EV_PKT_ERR.
> sfc 0000:0e:00.0: eth2: resetting (ALL)
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Please queue this for 3.0.y as well.

Applied and queued.
