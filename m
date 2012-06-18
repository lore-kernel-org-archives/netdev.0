From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM][RFC v1] Fix unexpected SA hard expiration after setting
 new date
Date: Mon, 18 Jun 2012 16:40:21 +0800
Message-ID: <20120618084021.GA24902@gondor.apana.org.au>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, fdu@windriver.com
To: "fan.du" <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:54607 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752272Ab2FRIkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 04:40:23 -0400
Content-Disposition: inline
In-Reply-To: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 18, 2012 at 04:24:15PM +0800, fan.du wrote:
> 
> So, could you please give your comments on this?

Well, this used to work back when we were using relative time
instead of absolute time.  Then someone came along and changed
it for suspend/resume.

I didn't like this new behaviour but Dave convinced me that
it is a good thing :)

I guess I can live with your workaround if Dave is happy with
it.  But IMHO we should just go back to relative time and fix
the suspend/resume user-space scripts instead.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
