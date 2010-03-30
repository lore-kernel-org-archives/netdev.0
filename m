From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/7] flow: structurize flow cache
Date: Tue, 30 Mar 2010 20:01:04 +0800
Message-ID: <20100330120104.GB5731@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-3-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:46405 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752809Ab0C3MBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:01:07 -0400
Content-Disposition: inline
In-Reply-To: <1269871964-5412-3-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 05:12:39PM +0300, Timo Teras wrote:
> Group all per-cpu data to one structure instead of having many
> globals. Also prepare the internals so that we can have multiple
> instances of the flow cache if needed.

Grouping everything together looks sane.  But adding the flow
cache pointer to everything seems to be unnecessary.  Why would
we need multiple flow caches?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
