From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2/2] [IPV4]: Use network-order dport for all visible inet_lookup_*
Date: Tue, 8 Aug 2006 14:29:14 +0100
Message-ID: <20060808132914.GA14433@infradead.org>
References: <20060808084614.GA6651@gondor.apana.org.au> <20060808084729.GA8085@gondor.apana.org.au> <20060808.022443.62664150.davem@davemloft.net> <20060808111140.GA15028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54712 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932586AbWHHN3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:29:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060808111140.GA15028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 09:11:40PM +1000, Herbert Xu wrote:
> On Tue, Aug 08, 2006 at 02:24:43AM -0700, David Miller wrote:
> > 
> > This isn't so nice because we will now byte-swap the port twice when
> > we try looking up a listening socket.  Once for the established lookup
> > and once for the listening hash lookup.
> > 
> > It should be easy to do the byte-swap once at a higher level right?
> 
> Good point.  This patch eliminates the double swap for __inet_lookup.
> 
> [IPV4]: Use network-order dport for all visible inet_lookup_*

Shouldn't it use __be16 types then?

