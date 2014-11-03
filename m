From: David Miller <davem@davemloft.net>
Subject: Re: macvtap: Fix csum_start when VLAN tags are present
Date: Mon, 03 Nov 2014 14:52:42 -0500 (EST)
Message-ID: <20141103.145242.1681559211164468290.davem@davemloft.net>
References: <20141103060125.GA28295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbaKCTwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:52:44 -0500
In-Reply-To: <20141103060125.GA28295@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 3 Nov 2014 14:01:25 +0800

> When VLAN is in use in macvtap_put_user, we end up setting
> csum_start to the wrong place.  The result is that the whoever
> ends up doing the checksum setting will corrupt the packet instead
> of writing the checksum to the expected location, usually this
> means writing the checksum with an offset of -4.
> 
> This patch fixes this by adjusting csum_start when VLAN tags are
> detected.
> 
> Fixes: f09e2249c4f5 ("macvtap: restore vlan header on user read")
> Cc: stable@vger.kernel.org
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
