From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix a possible events_get() race on
 BE2
Date: Fri, 23 Nov 2012 14:26:21 -0500 (EST)
Message-ID: <20121123.142621.70094578773386257.davem@davemloft.net>
References: <669f16b7-59f2-4587-af3e-0b6e83f8f68c@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab2KWT0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:26:24 -0500
In-Reply-To: <669f16b7-59f2-4587-af3e-0b6e83f8f68c@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 23 Nov 2012 15:57:18 +0530

> On BE2 chip, an interrupt being raised even when EQ is in un-armed state has
> been observed a few times.  This is not expected and has never been
> observed on BE3/Lancer chips.
> 
> As a consequence, be_msix()::events_get() and be_poll()::events_get()
> can race and notify an EQ wrongly causing a CEV UE. The other possible
> side-effect would be traffic stalling because after notifying EQ,
> napi_schedule() is ignored as NAPI is already running.
> 
> This patch fixes this issue by counting events only in be_poll().
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
