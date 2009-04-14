From: David Miller <davem@davemloft.net>
Subject: Re: gro: Restore correct value to gso_size
Date: Tue, 14 Apr 2009 15:11:24 -0700 (PDT)
Message-ID: <20090414.151124.62812233.davem@davemloft.net>
References: <20090414124249.GA31314@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mwagner@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751233AbZDNWLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 18:11:34 -0400
In-Reply-To: <20090414124249.GA31314@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 14 Apr 2009 20:42:49 +0800

> gro: Restore correct value to gso_size
> 
> Since everybody has been focusing on baremetal GRO performance
> no one noticed when I added a bug that zapped gso_size for all
> GRO packets.  This only gets picked up when you forward the skb
> out of an interface.
> 
> Thanks to Mark Wagner for noticing this bug when testing kvm.
> 
> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
