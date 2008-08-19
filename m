From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] atl1: disable TSO by default
Date: Tue, 19 Aug 2008 17:53:34 -0500
Message-ID: <20080819175334.28dc1c8e@osprey.hogchain.net>
References: <20080818192813.0d0dc1fd@osprey.hogchain.net>
	<E1KVQyr-0001Ui-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, link@miggy.org, ian@jeffray.co.uk,
	csnook@redhat.com, jie.yang@atheros.com, m@fhloston.org,
	davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:47808 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbYHSWyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 18:54:52 -0400
In-Reply-To: <E1KVQyr-0001Ui-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Aug 2008 23:10:37 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Jay Cliburn <jacliburn@bellsouth.net> wrote:

> >        netdev->features |= NETIF_F_LLTX;
> 
> Another new driver using LLTX, this is not good when we're trying
> to get rid of it.

The atl1 driver was merged in the spring of 2007, so I'm not sure I
consider it new (but your kernel development time horizon is undoubtedly
*way* longer than mine, so you may indeed consider it new). It was
basically a vendor driver that we modified to conform to kernel coding
standards. It started life, we believe, as pretty much a clone of the
e1000 driver circa 2005, so that's likely where it's use of LLTX
came from.

> 
> Perhaps we could just kill it by ignoring the LLTX flag and always
> grabbing the xmit lock.  That should be safe as long as none of these
> drivers grab the xmit lock within their private locks.

I'd be happy to gin up a patch if you could point me to a driver that
implements properly what you're asking.

Thanks,
Jay
