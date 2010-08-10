From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Tue, 10 Aug 2010 06:24:21 -0400
Message-ID: <20100810102421.GA28030@gondor.apana.org.au>
References: <20100806110511.GA16448@basil.fritz.box> <20100809213002.GA23736@gondor.apana.org.au> <20100810083040.GB6801@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51304 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab0HJKY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 06:24:57 -0400
Content-Disposition: inline
In-Reply-To: <20100810083040.GB6801@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 10:30:40AM +0200, Andi Kleen wrote:
. 
> This simple patch demonstrates double destroy. I have patches for showing
> the more complicated case too, but they're much more ugly.

Andi, I know you're seeing the problem, but I need to udnerstand
why, and this patch doesn't really answer the why part :)

So did you figure out why was calling it first (I presume you
know who called it the second time since you've got the back
trace)?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
