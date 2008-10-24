From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Fri, 24 Oct 2008 22:33:23 +0800
Message-ID: <20081024143323.GA14344@gondor.apana.org.au>
References: <20081011172002.GA12659@pest> <20081013.004226.171259546.davem@davemloft.net> <20081022074502.GA25058@gondor.apana.org.au> <20081022175704.GA25286@xw6200.broadcom.net> <20081023022001.GB304@gondor.apana.org.au> <1224782005.9142.2.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"berni@birkenwald.de" <berni@birkenwald.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38155 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754351AbYJXOdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 10:33:32 -0400
Content-Disposition: inline
In-Reply-To: <1224782005.9142.2.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2008 at 10:13:25AM -0700, Michael Chan wrote:
> 
> Yes, NETIF_F_TSO6 chips are a subset of NETIF_F_IPV6_CSUM chips.  In the
> code, these 2 bits are set independently and so the relationship is not
> obvious.  We should probably rearrange the code to make things more
> clear.

That's good to know.  I was afraid of adding a check in the
dev registration function in case your card actually needed
this.  Now that I know it doesn't we can check and disable it
if ever it happens.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
