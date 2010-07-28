From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] macvlan: Fix rx counters update in
	macvlan_handle_frame()
Date: Wed, 28 Jul 2010 08:14:04 +0800
Message-ID: <20100728001404.GA14038@gondor.apana.org.au>
References: <1280257807.27059.4.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50639 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab0G1AOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 20:14:15 -0400
Content-Disposition: inline
In-Reply-To: <1280257807.27059.4.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 12:10:07PM -0700, Sridhar Samudrala wrote:
> Fix macvlan_handle_frame() to update the rx counters based
> on the return value of the vlan->receive call.
> 
> Updated the patch to not do any packet count drops when the interface
> is down based on Herber'ts comments.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
