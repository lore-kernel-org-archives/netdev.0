From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Tue, 31 May 2016 08:49:45 +0800
Message-ID: <20160531004945.GA11422@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
 <20160530162759.GD8402@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:55302 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161685AbcEaAty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 20:49:54 -0400
Content-Disposition: inline
In-Reply-To: <20160530162759.GD8402@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 30, 2016 at 07:27:59PM +0300, Lennert Buytenhek wrote:
>
> That and stack switches to kworker threads and serialisation on
> the bc_queue queue lock.

My patch should resolve these problems too since the packet is
discarded if nobody is interested in it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
