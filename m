From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [BRIDGE]: Add support for NETIF_F_HW_CSUM devices
Date: Sat, 17 Jun 2006 22:06:57 -0700 (PDT)
Message-ID: <20060617.220657.112624502.davem@davemloft.net>
References: <20060613112511.GA13204@gondor.apana.org.au>
	<20060613112543.GA13253@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18341
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932097AbWFRFG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 01:06:58 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060613112543.GA13253@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Jun 2006 21:25:43 +1000

> [BRIDGE]: Add support for NETIF_F_HW_CSUM devices
> 
> As it is the bridge will only ever declare NETIF_F_IP_CSUM even if all
> its constituent devices support NETIF_F_HW_CSUM.  This patch fixes this
> by supporting the first one out of NETIF_F_NO_CSUM, NETIF_F_HW_CSUM,
> and NETIF_F_IP_CSUM that is supported by all constituent devices.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks a lot!
