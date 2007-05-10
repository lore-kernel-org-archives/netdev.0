From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:07:50 -0700 (PDT)
Message-ID: <20070510.150750.118628150.davem@davemloft.net>
References: <463F95C3.60407@goop.org>
	<20070508121322.GA21647@gondor.apana.org.au>
	<464395E5.2090500@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hch@infradead.org, ak@suse.de,
	akpm@linux-foundation.org, virtualization@lists.osdl.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org, jeff@garzik.org,
	shemminge@linux-foundation.org, rusty@rustcorp.com.au,
	Valdis.Kletnieks@vt.edu
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755987AbXEJWHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 18:07:48 -0400
In-Reply-To: <464395E5.2090500@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 10 May 2007 15:00:05 -0700

> Herbert Xu wrote:
> > [NET] link_watch: Move link watch list into net_device
> >
> > These days the link watch mechanism is an integral part of the
> > network subsystem as it manages the carrier status.  So it now
> > makes sense to allocate some memory for it in net_device rather
> > than allocating it on demand.
> 
> I think there's a problem with one of these two patches.

Yes, there are :-)

Did you catch the follow-on bug fixes?

