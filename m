From: David Miller <davem@davemloft.net>
Subject: Re: sit: Clean up DF code by copying from IPIP
Date: Tue, 10 Nov 2009 22:33:51 -0800 (PST)
Message-ID: <20091110.223351.123326243.davem@davemloft.net>
References: <20091106203741.GA19736@gondor.apana.org.au>
	<20091109184201.GA9493@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753072AbZKKGdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:33:25 -0500
In-Reply-To: <20091109184201.GA9493@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Nov 2009 13:42:01 -0500

> sit: Clean up DF code by copying from IPIP
> 
> This patch rearranges the SIT DF bit handling using the new IPIP
> DF code.  The only externally visible effect should be the case where
> PMTU is enabled and the MTU is exactly 1280 bytes.  In this case
> the previous code would send packets out with DF off while the new
> code would set the DF bit.  This is inline with RFC 4213.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6
