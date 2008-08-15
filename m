From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression
	for	iptables nat routing
Date: Fri, 15 Aug 2008 09:34:47 -0600
Message-ID: <1218814487.23510.28.camel@2710p.home>
References: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
	 <1218778238.23510.22.camel@2710p.home>
	 <20080815073343.GA20644@gondor.apana.org.au>
	 <20080815081442.GA20971@gondor.apana.org.au>
	 <20080815103235.GA31963@gondor.apana.org.au>
	 <20080815105318.GA5590@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:43228 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758851AbYHOPey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 11:34:54 -0400
In-Reply-To: <20080815105318.GA5590@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-08-15 at 20:53 +1000, Herbert Xu wrote:
> On Fri, Aug 15, 2008 at 08:32:35PM +1000, Herbert Xu wrote:
> > 
> > I'll work on the netfilter state preservation next.
> 
> Here it is:

Confirmed, these patches solve the problem.  Thanks Herbert.

-- 
Alex Williamson                             HP Open Source & Linux Org.

