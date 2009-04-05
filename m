From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Sun, 05 Apr 2009 02:59:20 -0700 (PDT)
Message-ID: <20090405.025920.75648090.davem@davemloft.net>
References: <20090402150908.GA1382@gondor.apana.org.au>
	<49D4D66A.50101@trash.net>
	<20090402153042.GB1670@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755769AbZDEJ7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 05:59:31 -0400
In-Reply-To: <20090402153042.GB1670@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Apr 2009 23:30:42 +0800

> On Thu, Apr 02, 2009 at 05:14:50PM +0200, Patrick McHardy wrote:
> >
> > I'd prefer that as well. The only reason to do this is to save a few
> > bytes and cycles for attribute encapsulation. I don't think this
> > matters at all, judging by the fact that I've never seen a userspace
> > implementation using message batching, the current users don't seem
> > to care about performance *that* much.
> 
> OK, let's all just keep an eye out for new struct users and see
> how it goes.

It might be about time to start working on netlink-2 seriously.
:-)

We can start treating it like a real protocol, firmly define
the endianness of everything to kill all the over-the-wire
issues, etc. and deal with this 4-byte-align stuff as well.

