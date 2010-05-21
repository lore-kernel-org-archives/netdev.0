From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix bogus gso_size on the first fraglist entry
Date: Thu, 20 May 2010 23:08:21 -0700 (PDT)
Message-ID: <20100520.230821.20952507.davem@davemloft.net>
References: <20100521024629.GA24700@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yugzhang@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754476Ab0EUGIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:08:12 -0400
In-Reply-To: <20100521024629.GA24700@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 21 May 2010 12:46:29 +1000

> gro: Fix bogus gso_size on the first fraglist entry
> 
> When GRO produces fraglist entries, and the resulting skb hits
> an interface that is incapable of TSO but capable of FRAGLIST,
> we end up producing a bogus packet with gso_size non-zero.
> 
> This was reported in the field with older versions of KVM that
> did not set the TSO bits on tuntap.
> 
> This patch fixes that.
> 
> Reported-by: Igor Zhang <yugzhang@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks!
