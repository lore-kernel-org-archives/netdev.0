From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: more info on ipsec-related invalid trusize
Date: Wed, 26 Nov 2008 13:57:44 +0800
Message-ID: <20081126055744.GA2891@gondor.apana.org.au>
References: <20081125042752.GA4085@x200.localdomain> <E1L4vWi-0006zm-PX@gondolin.me.apana.org.au> <20081125.215001.188137211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37737 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750696AbYKZF5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:57:52 -0500
Content-Disposition: inline
In-Reply-To: <20081125.215001.188137211.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2008 at 09:50:01PM -0800, David Miller wrote:
>
> Care to elaborate on this a little bit more to refresh
> everyone's memory and perhaps someone can work on a fix?

For a start have a look at xfrm_state_check_space where we expand
the packet without adjusting its truesize.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
