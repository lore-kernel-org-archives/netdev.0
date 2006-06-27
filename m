From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 27 Jun 2006 18:37:55 +1000
Message-ID: <20060627083755.GA26037@gondor.apana.org.au>
References: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl> <BAY103-F48CEDE1C901D0DF661A82B27E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35087 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932892AbWF0JiF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 05:38:05 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F48CEDE1C901D0DF661A82B27E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 08:45:52AM +0200, Marco Berizzi wrote:
> 
> >>Herbert Xu wrote:
> >>
> >>>However, the fact that the tcpdump causes more chunky packets to
> >>>make it through could be an indication that there is a bug somewhere
> >>>in our NAT/IPsec code or at least a suboptimal memory allocation
> >>>strategy that's somehow avoided when AF_PACKET pins the skb down.
> 
> JFYI: same problem with 2.6.17-git10 (tcpdump 'resolves' the
> problem)

Hey I thought your problem went away because your hardware is gone!
Just kidding :)

Seriously, I should have some time to spend on this soon once I push out
the current batch of Xen and crypto patches.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
