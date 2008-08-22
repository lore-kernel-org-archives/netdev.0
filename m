From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 21:02:19 +1000
Message-ID: <20080822110219.GA28666@gondor.apana.org.au>
References: <20080822084931.GB2645@ff.dom.local> <20080822.015513.194132430.davem@davemloft.net> <20080822100708.GA14345@gondor.apana.org.au> <20080822.032733.155458803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48265 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752184AbYHVLC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 07:02:26 -0400
Content-Disposition: inline
In-Reply-To: <20080822.032733.155458803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 03:27:33AM -0700, David Miller wrote:
> 
> We don't allow non-root ingress qdiscs.  All ingress qdiscs
> always take the device graft path, and always have a parent
> of TC_H_INGRESS, and always operate on rx_queue.

Ah yes, I forgot that the ingress qdisc is special, and that's
why we have the ifb device.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
