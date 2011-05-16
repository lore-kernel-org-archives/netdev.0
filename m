From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Fix oops in register dump after mapping
 change
Date: Mon, 16 May 2011 15:05:32 -0400 (EDT)
Message-ID: <20110516.150532.290926196560608104.davem@davemloft.net>
References: <1305562429.2885.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1EPTFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 15:05:37 -0400
In-Reply-To: <1305562429.2885.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 16 May 2011 17:13:49 +0100

> Commit 747df2258b1b9a2e25929ef496262c339c380009 ('sfc: Always map MCDI
> shared memory as uncacheable') introduced a separate mapping for the
> MCDI shared memory (MC_TREG_SMEM).  This means we can no longer easily
> include it in the register dump.  Since it is not particularly useful
> in debugging, substitute a recognisable dummy value.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
