From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Thu, 22 May 2008 07:39:52 +0800
Message-ID: <20080521233952.GA27138@gondor.apana.org.au>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au> <48344DAA.4060107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34310 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760514AbYEUXj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 19:39:58 -0400
Content-Disposition: inline
In-Reply-To: <48344DAA.4060107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2008 at 06:28:26PM +0200, Patrick McHardy wrote:
>
> I thought about this myself, my second idea was to add a
> mask for feature bits to be propagated. Unless there is a
> need for the driver to determine them at runtime, thats
> slightly simpler. The driver would do:
> 
> dev->vlan_features = NETIF_F_CSUM_ALL | ...
> 
> What do you think about this?

Yes that sounds great!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
