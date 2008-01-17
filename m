From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 23:50:16 +1100
Message-ID: <20080117125016.GA9820@gondor.apana.org.au>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi> <1200573750.4508.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49099 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750965AbYAQMuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:50:22 -0500
Content-Disposition: inline
In-Reply-To: <1200573750.4508.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2008 at 07:42:30AM -0500, jamal wrote:
> 
> Looking at the pfkey RFC one more time, heres a funny quote:
> "
> The dump message is used for debugging
> purposes only and is not intended for production use.
> "

In fact it goes much further:

   Support for the dump message MAY be discontinued in future versions
   of PF_KEY.  Key management applications MUST NOT depend on this
   message for basic operation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
