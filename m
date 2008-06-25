From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/4] lguest: Use GSO/IFF_VNET_HDR extensions on tun/tap
Date: Thu, 26 Jun 2008 01:45:18 +1000
Message-ID: <200806260145.19058.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260030.38293.rusty@rustcorp.com.au> <200806260032.12359.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, markmc@redhat.com,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34264 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277AbYFYPp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 11:45:58 -0400
In-Reply-To: <200806260032.12359.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 26 June 2008 00:32:12 Rusty Russell wrote:
> (Might not apply cleanly to current Linus, there are other lguest things
>  going on, but this gives you the idea at least).
...
> +	if (ioctl(netfd, TUNSETFEATURES,
> +		  TUN_F_CSUM|TUN_F_TSO4|TUN_F_TSO6|TUN_F_TSO_ECN) != 0)
> +		err(1, "Could not set features for tun device");

This should be TUNSETOFFLOAD of course.  I renamed it at the last minute, 
because TUNSETFEATURES implies symmetry with TUNGETFEATURES, which is 
completely different.

Cheers,
Rusty.
