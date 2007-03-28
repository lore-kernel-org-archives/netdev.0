From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] Re: Xen netfront fixes for changed skbuff in	net-2.6.22.git
Date: Thu, 29 Mar 2007 08:10:35 +1000
Message-ID: <20070328221035.GA10435@gondor.apana.org.au>
References: <460AB5A1.1000807@goop.org> <20070328214604.GA10231@gondor.apana.org.au> <460AE46C.9050805@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>,
	NetDev <netdev@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3675 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933589AbXC1WKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 18:10:42 -0400
Content-Disposition: inline
In-Reply-To: <460AE46C.9050805@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 02:55:56PM -0700, Jeremy Fitzhardinge wrote:
> 
> Hm, I was wondering if there's a nicer way of getting the same result. 
> Does it need to be done that way?

Actually you could use the skb->cb buffer which can store anything and
doesn't need to be cleaned up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
