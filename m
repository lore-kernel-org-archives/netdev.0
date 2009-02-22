From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: add loose reverse path filtering
Date: Sat, 21 Feb 2009 23:56:01 -0800 (PST)
Message-ID: <20090221.235601.92406212.davem@davemloft.net>
References: <20090220102536.2d39ddb9@extreme>
	<20090221130907.GA28765@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, hawk@diku.dk, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751969AbZBVH4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 02:56:20 -0500
In-Reply-To: <20090221130907.GA28765@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 21 Feb 2009 21:09:07 +0800

> Stephen Hemminger <shemminger@vyatta.com> wrote:
> > Extend existing reverse path filter option to allow strict or loose
> > filtering. (See http://en.wikipedia.org/wiki/Reverse_path_filtering).
> > 
> > For compatibility with existing usage, the value 1 is chosen for strict mode
> > and 2 for loose mode.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Rather than extending the rp_filter stuff any further, I'd prefer
> to see this replaced with netfilter plugin.

Normally I would agree, but in this case the cost is exactly
zero for the added flexibility.

So I'll apply this to net-next-2.6
