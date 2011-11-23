From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 16:21:21 +0800
Message-ID: <20111123082121.GA8108@gondor.apana.org.au>
References: <20111123075433.GA7928@gondor.apana.org.au> <1322035942.1298.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40552 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab1KWIVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 03:21:31 -0500
Content-Disposition: inline
In-Reply-To: <1322035942.1298.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 09:12:22AM +0100, Eric Dumazet wrote:
>
> I had no time to look at OVS, but current tc model is not scalable,
> everything is performed under a queue lock.
>
> Maybe its time to redesign a new model, based on modern techniques.

Indeed, I pointed this out numerous times over the past few years :)

However, this is something that we need to solve regardless of
whether OVS is added, since OVS isn't exactly going to replace the
packet scheduling layer.

> By the way, we seriously lack good documentation on tc, not counting
> many features. Code might be there, but without documenation, working
> samples, who can use it ?
>
> Take a look at last cls_flow extension, and try to use it on a real
> setup, you'll find its almost not possible...

lartc.org is surprisingly good.  But yes new features won't show
up there unless somebody contributes time to write it up.

Unfortunately while many love documentation, few are willing to
pay for it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
