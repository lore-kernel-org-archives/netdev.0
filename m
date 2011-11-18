From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: enforce minimum ring size
Date: Thu, 17 Nov 2011 21:44:20 -0500 (EST)
Message-ID: <20111117.214420.2096233269044701843.davem@davemloft.net>
References: <20111116234344.813201788@vyatta.com>
	<874ny2bgqa.fsf@turtle.gmx.de>
	<20111117163723.67964841@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab1KRCoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 21:44:24 -0500
In-Reply-To: <20111117163723.67964841@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 17 Nov 2011 16:37:23 -0800

> The hardware has a restriction that the minimum ring size possible
> is 128. The number of elements used is controlled by tx_pending and
> the overall number of elements in the ring tx_ring_size, therefore it
> is okay to limit the number of elements in use to a small value (63)
> but still provide a bigger ring.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to 'net'.
