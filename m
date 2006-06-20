From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge
Date: Tue, 20 Jun 2006 03:21:12 -0400
Message-ID: <4497A1E8.3030708@pobox.com>
References: <20060620070450.GA12609@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59844 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965108AbWFTHV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 03:21:27 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060620070450.GA12609@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi:
> 
> [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge
> 
> There has been an update to the forcedeth driver that added a few new
> uses of xmit_lock which is no longer meant to be used directly.  This
> patch replaces them with netif_tx_lock_bh.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

ACK.  I'll apply, if Linus doesn't pick this up...

	Jeff



