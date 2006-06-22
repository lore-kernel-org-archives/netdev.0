From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Prevent transmission after dev_deactivate
Date: Thu, 22 Jun 2006 02:28:36 -0700 (PDT)
Message-ID: <20060622.022836.21930135.davem@davemloft.net>
References: <20060622080856.GA21723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55503
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161013AbWFVJ2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 05:28:37 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622080856.GA21723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jun 2006 18:08:56 +1000

> I found a bug in my GSO patches with the shutdown handling in
> dev_deactivate.  It provided enough impetus for me to finally
> clean up this function :)
> 
> This patch is against Linus's tree.
> 
> [NET]: Prevent transmission after dev_deactivate

Looks good, applied, thanks a lot!
