From: David Miller <davem@davemloft.net>
Subject: Re: [UDP]: Clean up UDP-Lite receive checksum
Date: Tue, 06 Mar 2007 20:31:59 -0800 (PST)
Message-ID: <20070306.203159.126762793.davem@davemloft.net>
References: <20070306014100.GA31417@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932636AbXCGEcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:32:02 -0500
In-Reply-To: <20070306014100.GA31417@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Mar 2007 12:41:00 +1100

> Hi Dave:
> 
> [UDP]: Clean up UDP-Lite receive checksum
> 
> This patch eliminates some duplicate code for the verification of
> receive checksums between UDP-Lite and UDP.  It does this by
> introducing __skb_checksum_complete_head which is identical to
> __skb_checksum_complete_head apart from the fact that it takes
> a length parameter rather than computing the first skb->len bytes.
> 
> As a result UDP-Lite will be able to use hardware checksum offload
> for packets which do not use partial coverage checksums.  It also
> means that UDP-Lite loopback no longer does unnecessary checksum
> verification.
> 
> If any NICs start support UDP-Lite this would also start working
> automatically.
> 
> This patch removes the assumption that msg_flags has MSG_TRUNC clear
> upon entry in recvmsg.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks a lot.
