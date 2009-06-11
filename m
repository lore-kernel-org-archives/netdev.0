From: David Miller <davem@davemloft.net>
Subject: Re: virtio-net header alignment
Date: Thu, 11 Jun 2009 05:39:30 -0700 (PDT)
Message-ID: <20090611.053930.255217615.davem@davemloft.net>
References: <200905251601.29327.rusty@rustcorp.com.au>
	<1243268223.32745.25.camel@blaa>
	<20090610051227.GB16563@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, rusty@rustcorp.com.au, kudinskas@uk.ibm.com,
	aliguori@linux.vnet.ibm.com, pablo@uk.ibm.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753695AbZFKMj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 08:39:27 -0400
In-Reply-To: <20090610051227.GB16563@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Jun 2009 15:12:27 +1000

> On Mon, May 25, 2009 at 05:17:03PM +0100, Mark McLoughlin wrote:
>> 
>> Perhaps; would padding struct virtio_net_hdr_mrg_rxbuf have avoided it?
>> 
>> Cc-ing Herbert, he initially wrote the guest side of this.
> 
> Does this fix it?
> 
> virtio_net: Fix IP alignment on mergeable RX path
> 
> We need to enforce the IP alignment on the mergeable RX path just
> like the other RX path.  Not doing so results in misaligned IP
> headers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll apply this as soon as I see some test reports.

Has anyone had a chance to try this out yet?
