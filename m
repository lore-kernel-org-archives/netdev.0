From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Warn about GSO/checksum abuse
Date: Mon, 23 Apr 2007 22:37:19 -0700 (PDT)
Message-ID: <20070423.223719.09950805.davem@davemloft.net>
References: <20070424035542.GA29189@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33921
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161632AbXDXFhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:37:12 -0400
In-Reply-To: <20070424035542.GA29189@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Apr 2007 13:55:42 +1000

> [NET]: Warn about GSO/checksum abuse
> 
> Now that Patrick has added the code to deal with GSO in netfilter,
> we no longer need the crutch that computes partial checksums just
> before transmission.
> 
> This patch turns this into a warning again.  If this goes OK, we
> can then turn it into a BUG_ON and remove the gso_send_check cruft.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for keeping track of this.

Applied, thanks Herbert.
