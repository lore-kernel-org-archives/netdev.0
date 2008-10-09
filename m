From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/4] inet: Make tunnel RX/TX byte counters more
 consistent
Date: Thu, 09 Oct 2008 12:03:27 -0700 (PDT)
Message-ID: <20081009.120327.119334632.davem@davemloft.net>
References: <20081009070424.GA16684@gondor.apana.org.au>
	<20081009112308.GB19075@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, philipc@snapgear.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756517AbYJITDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:03:52 -0400
In-Reply-To: <20081009112308.GB19075@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 9 Oct 2008 19:23:08 +0800

> inet: Make tunnel RX/TX byte counters more consistent
> 
> This patch makes the RX/TX byte counters for IPIP, GRE and SIT more
> consistent.  Previously we included the external IP headers on the
> way out but not when the packet is inbound.
> 
> The new scheme is to count payload only in both directions.  For
> IPIP and SIT this simply means the exclusion of the external IP
> header.  For GRE this means that we exclude the GRE header as
> well.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
