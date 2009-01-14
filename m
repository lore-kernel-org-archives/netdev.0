From: David Miller <davem@davemloft.net>
Subject: Re: gro: Check for GSO packets and packets with frag_list
Date: Wed, 14 Jan 2009 14:36:24 -0800 (PST)
Message-ID: <20090114.143624.145128481.davem@davemloft.net>
References: <20090114215639.GA25069@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753111AbZANWgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:36:23 -0500
In-Reply-To: <20090114215639.GA25069@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 08:56:39 +1100

> gro: Check for GSO packets and packets with frag_list
> 
> As GRO cannot be applied to packets with frag_list we need to
> make sure that we reject such packets if they are fed to us,
> e.g., through a tunnel device.
> 
> Also there is no point in applying GRO on GSO packets so they
> too should be rejected.  This allows GRO to be used in virtio-net
> which may produce GSO packets directly but may still benefit
> from GRO if the other end of it doesn't support GSO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
