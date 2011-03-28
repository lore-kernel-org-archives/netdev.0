From: David Miller <davem@davemloft.net>
Subject: Re: mlx4_en: Fix loss of promiscuity
Date: Sun, 27 Mar 2011 18:43:43 -0700 (PDT)
Message-ID: <20110327.184343.02285552.davem@davemloft.net>
References: <20110327110126.GA25595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52369
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753252Ab1C1BoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:44:21 -0400
In-Reply-To: <20110327110126.GA25595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 27 Mar 2011 19:01:26 +0800

> mlx4_en: Fix loss of promiscuity
> 
> The mlx4_en driver uses the combination stop_port/start_port
> in a number of places.  Unfortunately that causes any promiscuous
> mode settings on the hardware to be lost.
> 
> This patch fixes that problem.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
