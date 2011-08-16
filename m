From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] ethtool: Correct description of
 'max_coalesced_frames' fields
Date: Tue, 16 Aug 2011 16:36:48 -0700 (PDT)
Message-ID: <20110816.163648.1633803245748781972.davem@davemloft.net>
References: <1313453180.2731.57.camel@bwh-desktop>
	<1313453267.2731.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eli@dev.mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab1HPXgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 19:36:50 -0400
In-Reply-To: <1313453267.2731.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 16 Aug 2011 01:07:47 +0100

> The current descriptions state that these fields specify 'How many
> packets to delay ... after a packet ...' which implies that the
> hardware should wait for (max_coalesced_frames + 1) completions before
> generating an interrupt.  It is also stated that setting both this
> field and the corresponding 'coalesce_usecs' field to 0 is invalid.
> Together, this implies that the hardware must always be configured
> to delay a completion IRQ for at least 1 usec or 1 more completion.
> 
> I believe that the addition of 1 is not intended, and David Miller
> confirms that the original implementation (in tg3) does not do this.
> Clarify the descriptions of these fields to avoid this interpretation.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
