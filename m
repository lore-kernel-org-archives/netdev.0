From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Sun, 05 Apr 2009 02:57:28 -0700 (PDT)
Message-ID: <20090405.025728.246747388.davem@davemloft.net>
References: <49D4D260.6020809@trash.net>
	<20090402145952.GA1276@gondor.apana.org.au>
	<49D4D480.9030306@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756165AbZDEJ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 05:57:39 -0400
In-Reply-To: <49D4D480.9030306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 02 Apr 2009 17:06:40 +0200

> Herbert Xu wrote:
> > If we can ensure that all netlink backends use the helpers that
> > copy, even for structures then it should definitely work.
> 
> Yes, that should always work.

It should work on the kernel side, the user side is still broken
and I can show you the hacks in libnl to prove it :-)

