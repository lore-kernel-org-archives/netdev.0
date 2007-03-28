From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Xen netfront fixes for changed skbuff in net-2.6.22.git
Date: Thu, 29 Mar 2007 07:46:04 +1000
Message-ID: <20070328214604.GA10231@gondor.apana.org.au>
References: <460AB5A1.1000807@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xen-devel <xen-devel@lists.xensource.com>,
	NetDev <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3562 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752897AbXC1VqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 17:46:23 -0400
Content-Disposition: inline
In-Reply-To: <460AB5A1.1000807@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeremy:

On Wed, Mar 28, 2007 at 11:36:17AM -0700, Jeremy Fitzhardinge wrote:
> 
> I wonder if you've got a chance to look at netfront in light of the new
> stuff in davem's network tree  (the stuff that's in
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.22.git).

I've had a look at now and you can just stuff it into one of the other
pointers that's still there.  We just need to make sure that it is
reset properly before we feed the packet into the stack.  The pointer
skb->dev is one candidate but there are plenty of others.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
