From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Wed, 14 Nov 2007 01:07:22 -0800 (PST)
Message-ID: <20071114.010722.141237256.davem@davemloft.net>
References: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au>
	<4732F1B1.204@trash.net>
	<20071108112921.GB16688@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753081AbXKNJHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:07:23 -0500
In-Reply-To: <20071108112921.GB16688@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Nov 2007 19:29:21 +0800

> On Thu, Nov 08, 2007 at 12:23:29PM +0100, Patrick McHardy wrote:
> >
> > We have a few places that go though the trouble of selecting the
> > "correct" hook value for the address family, even though the numerical
> > values are identical. How about we just get rid of the different
> > naming and use NF_INET_... for both IPv4 and IPv6?
> 
> Nice work! Thanks Patrick.

Yeah I like it too, applied to net-2.6.25

I had to do some minor rediffing to make it go in cleanly after
Herbert's work, so I'm doing some build testing before I push this bit
onto kernel.org

Thanks again Patrick.
