From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 05 Nov 2008 03:54:54 -0800 (PST)
Message-ID: <20081105.035454.87914782.davem@davemloft.net>
References: <20081027.113904.211811887.davem@davemloft.net>
	<20081105.034224.167388197.davem@davemloft.net>
	<20081105114900.GA18691@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755337AbYKELzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 06:55:19 -0500
In-Reply-To: <20081105114900.GA18691@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 5 Nov 2008 14:49:00 +0300

> But what if we just remove that trimming at all? This may result in
> a not fully filled tso frame, but who cares if we copy data from
> userspace anyway, will add another potentially small copy at sending
> time?

Ok, the only part I care about is whether taking away this modulus
will result in a sub-MSS sized packet on the wire, which is
undesirable.

The send logic will prevent this, right?

If so, yes I agree, we can delete this.
