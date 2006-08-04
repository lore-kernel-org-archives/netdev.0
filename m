From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 20:25:57 +1000
Message-ID: <20060804102557.GA17723@gondor.apana.org.au>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au> <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com> <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2> <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au> <20060804083734.GA16082@gondor.apana.org.au> <20060804101017.GA17393@gondor.apana.org.au> <1154686563.5187.43.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:65297 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161131AbWHDK0L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:26:11 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154686563.5187.43.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 06:16:03AM -0400, jamal wrote:
> 
> I still have my setup intact, so i will give this a whirl in about 3-4
> hours. It does look promising - an atomic should be a lot cheaper than a
> lock. Thanks Herbert.

Well it's not that good since the current code only takes the
lock in exceptional circumstances while my patch does the atomic
op unconditionally.

But then again the current code is wrong :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
