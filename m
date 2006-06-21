From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Thu, 22 Jun 2006 09:27:41 +1000
Message-ID: <20060621232741.GA21559@gondor.apana.org.au>
References: <20060620090919.GA31613@gondor.apana.org.au> <20060620091050.GA31854@gondor.apana.org.au> <1150926495.3475.5.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13323 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751484AbWFUX2P
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 19:28:15 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1150926495.3475.5.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael:

On Wed, Jun 21, 2006 at 02:48:15PM -0700, Michael Chan wrote:
> 
> We have some hardware that supports TSO and ECN.  Is something like the
> patch below what you had in mind to support NETIF_F_TSO_ECN?  Or are you
> thinking about something more generic that works with or without
> hardware support?

Yeah I was thinking of something more generic because packets with CWR
set should be rare.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
