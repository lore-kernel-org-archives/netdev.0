From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 18:29:16 +0800
Message-ID: <20070927102916.GA15749@gondor.apana.org.au>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4554 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753074AbXI0K3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 06:29:31 -0400
Content-Disposition: inline
In-Reply-To: <20070927100753.GA22323@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 02:07:53PM +0400, Evgeniy Polyakov wrote:
>
> It forces all inpuit/pre/post/forward hooks to be enbled not as a direct
> function call, but as additional lookups. And unability to remove
> netfilter from config. And just because of couple of checksum helpers...

I'm certainly not against patches moving that code out of
netfilter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
