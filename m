From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Multicast and hardware checksum
Date: Fri, 8 Jun 2007 21:06:21 +1000
Message-ID: <20070608110621.GA23842@gondor.apana.org.au>
References: <E1HwXpK-0005RC-00@gondolin.me.apana.org.au> <46693743.7090100@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3647 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S938246AbXFHLGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:06:23 -0400
Content-Disposition: inline
In-Reply-To: <46693743.7090100@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 02:02:27PM +0300, Baruch Even wrote:
> 
> As far as IGMP and multicast handling everything works, the packets are 
> even forwarded over the ppp links but they arrive to the client with a 
> bad checksum. I don't have the trace in front of me but I believe it was 
> the UDP checksum that failed.

What kind of a ppp device is this?

If you run a tcpdump either side of the ppp link do you see the same
UDP checksum value?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
