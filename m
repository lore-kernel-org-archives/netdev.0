From: David Miller <davem@davemloft.net>
Subject: Re: net: Enable TSO if supported by at least one device
Date: Mon, 08 Sep 2008 16:10:16 -0700 (PDT)
Message-ID: <20080908.161016.259741666.davem@davemloft.net>
References: <20080908084203.GA14168@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752274AbYIHXKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 19:10:22 -0400
In-Reply-To: <20080908084203.GA14168@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 8 Sep 2008 18:42:03 +1000

> net: Enable TSO if supported by at least one device
> 
> As it stands users of netdev_compute_features (e.g., bridges/bonding)
> will only enable TSO if all consituent devices support it.  This
> is unnecessarily pessimistic since even on devices that do not
> support hardware TSO and SG, emulated TSO still performs to a par
> with TSO off.
> 
> This patch enables TSO if at least on constituent device supports
> it in hardware.
> 
> The direct beneficiaries will be virtualisation that uses bridging
> since this means that TSO will always be enabled for communication
> from the host to the guests.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks Herbert.
