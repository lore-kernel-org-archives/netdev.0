From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix INTx ISR for interrupt behaviour
 on BE2
Date: Wed, 28 Nov 2012 11:35:22 -0500 (EST)
Message-ID: <20121128.113522.1518543032530471175.davem@davemloft.net>
References: <d856540b-bacc-45e3-a7cc-49e7febafb95@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575Ab2K1QfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:35:24 -0500
In-Reply-To: <d856540b-bacc-45e3-a7cc-49e7febafb95@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 28 Nov 2012 11:20:02 +0530

> On BE2 chip, an interrupt may be raised even when EQ is in un-armed state.
> As a result be_intx()::events_get() and be_poll:events_get() can race and
> notify an EQ wrongly.
> 
> Fix this by counting events only in be_poll(). Commit 0b545a629 fixes
> the same issue in the MSI-x path.
> 
> But, on Lancer, INTx can be de-asserted only by notifying num evts. This
> is not an issue as the above BE2 behavior doesn't exist/has never been
> seen on Lancer.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
