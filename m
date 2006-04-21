From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 12:40:24 +1000
Message-ID: <20060421024024.GA29644@gondor.apana.org.au>
References: <1145578214.3195.6.camel@rh4> <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawvrana@gmail.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3844 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932219AbWDUCka
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 22:40:30 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2006 at 12:37:36PM +1000, Herbert Xu wrote:
> 
> Rather than dealing with this individually in each driver perhaps we should
> come up with a more centralised solution?

One simple solution is to establish a separate queue for RTNL-holding
users or vice versa for non-RTNL holding networking users.  That
would allow the drivers to safely flush the non-RTNL queue while
holding the RTNL.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
