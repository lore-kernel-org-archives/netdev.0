From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Thu, 02 Apr 2009 02:50:22 -0700 (PDT)
Message-ID: <20090402.025022.241387805.davem@davemloft.net>
References: <20090304.030044.163418715.davem@davemloft.net>
	<20090402093952.GA30553@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755411AbZDBJue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:50:34 -0400
In-Reply-To: <20090402093952.GA30553@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Apr 2009 17:39:52 +0800

> (Catching up with old emails)
> 
> David Miller <davem@davemloft.net> wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Wed, 04 Mar 2009 11:06:41 +0100
> > 
> >> It should also be noted that netlink attributes only provide 4 byte
> >> alignment. Not sure what the current status of handling unaligned
> >> accesses on all architectures is, but something that might have to
> >> be taken into consideration.
> > 
> > Indeed, we have hacks in libnl to work around some of these
> > issues :-(
> 
> Requiring the use of aligned_u64 instead of __u64 in netlink
> structs should help with new data structures, right?

Yes, it should.
