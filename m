From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next 1/3] bridge: use the bridge IP addr as source
 addr of querier
Date: Mon, 29 Apr 2013 15:43:01 +0800
Message-ID: <20130429074301.GA14021@gondor.apana.org.au>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50290 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751658Ab3D2HnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 03:43:09 -0400
Content-Disposition: inline
In-Reply-To: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 03:26:30PM +0800, Cong Wang wrote:
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

I don't think we should make this the default.  Having it as an
option though is fine with me.  We may also want to allow the user
to explicitly set an IP address.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
