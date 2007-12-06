From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions of sysctl and proc handler for conf.all.forwarding
Date: Thu, 6 Dec 2007 22:06:01 +1100
Message-ID: <20071206110601.GA30402@gondor.apana.org.au>
References: <20071205.020645.171664472.davem@davemloft.net> <E1J04N1-0006uU-00@gondolin.me.apana.org.au> <20071205.213933.40987728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1434 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751391AbXLFLGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 06:06:04 -0500
Content-Disposition: inline
In-Reply-To: <20071205.213933.40987728.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 09:39:33PM -0800, David Miller wrote:
>
> But we go back again to the question of how to get this "current
> behavior" setting instantiated early enough.  So much stuff happens
> via initrd's etc. before the real userland has a change to run things,
> read setting from the real filesystem config giles, in order to change
> this.

Perhaps a boot time command line option?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
