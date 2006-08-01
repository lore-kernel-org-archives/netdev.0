From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 17:45:04 +1000
Message-ID: <20060801074504.GA4272@gondor.apana.org.au>
References: <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801072358.GB3802@gondor.apana.org.au> <20060801.003614.54188740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57613 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161341AbWHAHpX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:45:23 -0400
To: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060801.003614.54188740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 12:36:14AM -0700, David Miller wrote:
> 
> > > - tc_verd/tc_index/input_dev: when directing a packet from a device
> > >   supporting GSO to a device not supporting GSO using tc actions,
> > >   these fields may be set.
> > 
> > This doesn't look right though.  GSO should occur just before
> > hard_start_xmit (after all tc actions have taken place) so we
> > shouldn't have any more tc actions to perform.
> 
> Hmmm, what about loopback?  Yeah yeah, LOOPBACK_TSO is not defined :)
> but what I'm really referring to is that loopback preserves the
> traffic classifier bits of the skb.

I don't know.  Jamal, is there a scenario where these three attributes
are needed for loopback packets?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
