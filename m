From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
	input routes
Date: Thu, 24 Nov 2011 08:10:35 +0800
Message-ID: <20111124001035.GA14996@gondor.apana.org.au>
References: <20111123121450.GE6348@secunet.com> <20111123155245.GA11638@gondor.apana.org.au> <20111123.164941.1950228526500366081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51681 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab1KXAKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:10:42 -0500
Content-Disposition: inline
In-Reply-To: <20111123.164941.1950228526500366081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 04:49:41PM -0500, David Miller wrote:
>
> The issue is that "we", the forwarding entity, end up with a cached on
> the input route and report this cached PMTU to the sender.
> 
> This takes a while to time out.

I understand.  However, this could be seen as an optimisation
as if somehow we as a router discovered the smaller MTU this
would save everybody behind us from having to disocver it by
probing until our discovery expires.

Is there a particular scenario where this breaks? I could only think
of policy routing cases but that's not unique to forwarding as it
also affects us as a host.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
