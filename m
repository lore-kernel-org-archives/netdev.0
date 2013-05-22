From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v5 1/3] bridge: use the bridge IP addr as
 source addr for querier
Date: Wed, 22 May 2013 15:55:19 +0800
Message-ID: <20130522075519.GA15155@gondor.apana.org.au>
References: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58661 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753187Ab3EVHzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 03:55:25 -0400
Content-Disposition: inline
In-Reply-To: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 03:52:54PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Quote from Adam:
> "If it is believed that the use of 0.0.0.0
> as the IP address is what is causing strange behaviour on other devices
> then is there a good reason that a bridge rather than a router shouldn't
> be the active querier? If not then using the bridge IP address and
> having the querier enabled by default may be a reasonable solution
> (provided that our querier obeys the election rules and shuts up if it
> sees a query from a lower IP address that isn't 0.0.0.0). Just because a
> device is the elected querier for IGMP doesn't appear to mean it is
> required to perform any other routing functions."
> 
> And introduce a new troggle for it, as suggested by Herbert.
> 
> Suggested-by: Adam Baker <linux@baker-net.org.uk>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Adam Baker <linux@baker-net.org.uk>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

to all three patches.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
