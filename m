From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sun, 10 Aug 2008 09:59:37 +0800
Message-ID: <20080810015937.GB1859@gondor.apana.org.au>
References: <200807171653.59177.wolfgang.walter@stwm.de> <489DC05E.2080901@zytor.com> <20080810002937.GA1461@gondor.apana.org.au> <200808100356.56432.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40763 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753072AbYHJB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 21:59:49 -0400
Content-Disposition: inline
In-Reply-To: <200808100356.56432.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2008 at 03:56:56AM +0200, Wolfgang Walter wrote:
> On Sunday 08 August 2008, Herbert Xu wrote:
> > Someone please test this with tcrypt mode=200 with and without
> > the patch.
> 
> Here are the results:

Thanks, so for IPsec it's about a 10% increase in CPU utilisation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
