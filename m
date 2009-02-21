From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip: add loose reverse path filtering
Date: Sat, 21 Feb 2009 21:09:07 +0800
Message-ID: <20090221130907.GA28765@gondor.apana.org.au>
References: <20090220102536.2d39ddb9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hawk@diku.dk, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34157 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751587AbZBUNJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 08:09:16 -0500
Content-Disposition: inline
In-Reply-To: <20090220102536.2d39ddb9@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
> Extend existing reverse path filter option to allow strict or loose
> filtering. (See http://en.wikipedia.org/wiki/Reverse_path_filtering).
> 
> For compatibility with existing usage, the value 1 is chosen for strict mode
> and 2 for loose mode.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Rather than extending the rp_filter stuff any further, I'd prefer
to see this replaced with netfilter plugin.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
