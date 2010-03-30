From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/7] flow: delayed deletion of flow cache entries
Date: Tue, 30 Mar 2010 20:36:12 +0800
Message-ID: <20100330123612.GB6174@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-5-git-send-email-timo.teras@iki.fi> <20100330122217.GF5731@gondor.apana.org.au> <4BB1EF7A.7030407@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:60679 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754445Ab0C3MgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:36:15 -0400
Content-Disposition: inline
In-Reply-To: <4BB1EF7A.7030407@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 03:32:58PM +0300, Timo Ter=E4s wrote:
> If flow cache regeneration or shrinking is triggered in lookup,
> it would previously free it in place. Now that is deferred. But
> yes, it's more useful after the next patches that call the
> virtual destructor. Should have explained this better.

Any chance you can refactor them so that this comes after the
virtual get/put patch?

That way can evaluate this on its own merit rather than being
a prerequisite for the more important stuff.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
