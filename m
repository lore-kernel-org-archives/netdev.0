From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 1/1] pch_gbe: replace private tx ring lock
 with common netif_tx_lock
Date: Thu, 28 Apr 2016 17:21:56 -0400 (EDT)
Message-ID: <20160428.172156.82071103410592107.davem@davemloft.net>
References: <20160427212944.GB10269@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	dvhart@infradead.org, andy.cress@us.kontron.com,
	bryan@fossetcon.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbcD1VV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:21:59 -0400
In-Reply-To: <20160427212944.GB10269@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 27 Apr 2016 23:29:44 +0200

> pch_gbe_tx_ring.tx_lock is only used in the hard_xmit handler and
> in the transmit completion reaper called from NAPI context.
> 
> Compile-tested only. Potential victims Cced.
> 
> Someone more knowledgeable may check if pch_gbe_tx_queue could
> have some use for a mmiowb.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Darren Hart <dvhart@infradead.org>
> Cc: Andy Cress <andy.cress@us.kontron.com>
> Cc: bryan@fossetcon.org
> 
> ---
>  Includes Nikolay's fix.

Applied, thank you.
