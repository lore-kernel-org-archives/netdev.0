From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 18:44:26 +1000
Message-ID: <20100519084426.GA24616@gondor.apana.org.au>
References: <20100519075721.GA23926@gondor.apana.org.au> <1274256582.2766.5.camel@edumazet-laptop> <20100519082047.GA24331@gondor.apana.org.au> <1274257637.2766.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56122 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750961Ab0ESIoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:44:34 -0400
Content-Disposition: inline
In-Reply-To: <1274257637.2766.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 10:27:17AM +0200, Eric Dumazet wrote:
> 
> This is a bit wrong, at least here (CONFIG_4KSTACKS=y)
> 
> Some people still use 32bits these days ;)
> 
> Please check arch/x86/kernel/irq_32.c

Right, I was looking at the generic version.

Still, as I'm only changing tun.c where we know the call comes
from a syscall, I don't think the stack is a great issue.

Besides, for TX we already perform everything from the same stack
depth and the TX path isn't that much shallower compared to the
RX path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
