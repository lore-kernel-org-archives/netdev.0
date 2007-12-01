From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 2/2][NEIGH] Use the ctl paths to create neighbours sysctls
Date: Sun, 2 Dec 2007 00:09:23 +1100
Message-ID: <20071201130922.GD15910@gondor.apana.org.au>
References: <4750486C.2000301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751083AbXLANJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:09:25 -0500
Content-Disposition: inline
In-Reply-To: <4750486C.2000301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 08:29:16PM +0300, Pavel Emelyanov wrote:
> Since the path is modified, it is put on the stack, to avoid
> possible races with multiple calls to neigh_sysctl_register() : it
> is called by protocols and I didn't find any protection in this
> case. Did I overlooked the rtnl lock?. 

I think the only caller that can be a module is IPv6 :)

> The stack growth of the neigh_sysctl_register() is 40 bytes. I
> believe this is OK, since this is not that much and this function 
> is not called with the deep stack (device/protocols register).

Yes it's fine.

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Both applied to net-2.6.25.  Thanks Pavel!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
