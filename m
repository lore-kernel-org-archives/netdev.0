From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next 3/3] bridge: send query as soon as leave is
 received
Date: Mon, 29 Apr 2013 15:43:58 +0800
Message-ID: <20130429074358.GB14021@gondor.apana.org.au>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
 <1367220392-17496-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40511 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750970Ab3D2HoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 03:44:00 -0400
Content-Disposition: inline
In-Reply-To: <1367220392-17496-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 03:26:32PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Continue sending queries when leave is received if the user marks
> it as a querier.

If we're going to send a query on leave it should be group-specific
and not general.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
