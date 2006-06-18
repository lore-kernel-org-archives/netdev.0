From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [NET]: Add NETIF_F_GEN_CSUM and NETIF_F_ALL_CSUM
Date: Sat, 17 Jun 2006 22:06:24 -0700 (PDT)
Message-ID: <20060617.220624.55509962.davem@davemloft.net>
References: <20060613112511.GA13204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17317
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932091AbWFRFG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 01:06:27 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060613112511.GA13204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Jun 2006 21:25:11 +1000

> [NET]: Add NETIF_F_GEN_CSUM and NETIF_F_ALL_CSUM
> 
> The current stack treats NETIF_F_HW_CSUM and NETIF_F_NO_CSUM identically
> so we test for them in quite a few places.  For the sake of brevity, I'm
> adding the macro NETIF_F_GEN_CSUM for these two.  We also test the disjunct
> of NETIF_F_IP_CSUM and the other two in various places, for that purpose
> I've added NETIF_F_ALL_CSUM.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
