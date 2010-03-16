From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bridge] [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 16 Mar 2010 10:48:12 +0800
Message-ID: <20100316024812.GA17535@gondor.apana.org.au>
References: <20100302092209.048f5682@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36262 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756467Ab0CPCsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 22:48:19 -0400
Content-Disposition: inline
In-Reply-To: <20100302092209.048f5682@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> Bridge is already using lockless transmit LLTX, so tx_lock is not touched.

LLTX doesn't actually buy you anything since you're still going
through a single qdisc.  To get the full benefits of the per-cpu
counters you need to implement multiqueue support in the bridge.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
