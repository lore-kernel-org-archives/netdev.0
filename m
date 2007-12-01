From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 1/3][IPV4] Cleanup the devinet_sysctl_register
Date: Sun, 2 Dec 2007 00:18:16 +1100
Message-ID: <20071201131815.GF15910@gondor.apana.org.au>
References: <4750548C.1040005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3512 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751816AbXLANSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:18:17 -0500
Content-Disposition: inline
In-Reply-To: <4750548C.1040005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 09:21:00PM +0300, Pavel Emelyanov wrote:
> I moved the call to kmalloc() from the *t declaration into 
> the code (this is confusing when a variable is initialized
> with the result of some call) and removed unneeded comment 
> near the error path. Just like I did with the neigh ctl-s.
> 
> Besides, I fixed the goto's and the labels - they were indented
> with spaces :(
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25.  Thanks.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
