From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:39:36 +0100
Message-ID: <1217500776.3454.136.camel@pmac.infradead.org>
References: <20080730140136.42223e3c@extreme> <20080730233551.76fd38a8@surf>
	 <20080730144812.a71156f7.akpm@linux-foundation.org>
	 <20080730.145727.07367670.davem@davemloft.net>
	 <20080730151316.a4d76fe9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60302 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbYGaKkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:40:12 -0400
In-Reply-To: <20080730151316.a4d76fe9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 15:13 -0700, Andrew Morton wrote:
> On Wed, 30 Jul 2008 14:57:27 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> > I'm sure you can find someone who runs with CONFIG_STAND_ON_MY_HEAD=y
> > but that doesn't mean that supporting such an option upstream makes
> > any sense.

That's not entirely consistent with Linus' observations on similar
topics. He seems to think that if people need certain things and would
be patching them in anyway, then it makes sense to merge them upstream.

> Well yes, embedded developers do patch the hell out of their kernels
> and presumably they will always do so.  The idea here is to bring
> things inwards to reduce the amount of patching which these people
> need to do.

Distro vendors used to do that too.

We need to be moving towards a situation where people don't _need_ to
patch the hell out of their kernels to make Linux viable for embedded
devices. I'm not prepared just assume that 'they will always do so', and
I'm disappointed to hear Andrew say such a thing. 

We need to do better than that.

In particular, we need not to simultaneously:
 - whine that "embedded" folks never submit their work upstream, and
 - reject it on ideological grounds when they do, citing totally bogus
   'technical' reasons.

Dave, if you won't take these patches then I will (after review) put
them in the embedded-2.6 tree with Andrew's sign-off, and ask Linus to
pull them into 2.6.28 directly from there rather than via your tree.
I think he'll take them, because it's the right thing to do.

I would prefer not to have to do that; please reconsider your refusal.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



