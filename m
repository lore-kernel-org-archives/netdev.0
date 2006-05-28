From: David Miller <davem@davemloft.net>
Subject: Re: [1/4] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Sat, 27 May 2006 23:03:02 -0700 (PDT)
Message-ID: <20060527.230302.85071200.davem@davemloft.net>
References: <20060527.210519.119151107.yoshfuji@linux-ipv6.org>
	<E1FjxaL-0002Gv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10721
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750726AbWE1GCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 May 2006 02:02:48 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FjxaL-0002Gv-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 May 2006 22:08:01 +1000

> YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> > In article <20060527113345.GA4737@gondor.apana.org.au> (at Sat, 27 May 2006 21:33:45 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> > 
> >> As far as I can gather it's an attempt to guard against the removal of
> >> the corresponding modules.  Since neither module can be unloaded at all
> >> we can leave it to whoever fixes up IPv6 unloading :)
> > 
> > I disagree. Please do not add another mess.
> 
> Please don't get me wrong.  What I removed here doesn't work at all to
> begin with.  I was just pointing out the possible reason why this code
> existed in the first place.

Right the existing code didn't work at all.  Herbert is not
making things any worse or less functional.  The task for
making ipv6 unloadable as a module remains equally arduous
both before and after Herbert's changes :-)
