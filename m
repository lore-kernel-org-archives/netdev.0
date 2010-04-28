From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: potential uninitialized variable num_xfrms
Date: Wed, 28 Apr 2010 09:41:55 -0700 (PDT)
Message-ID: <20100428.094155.09744376.davem@davemloft.net>
References: <1272439222-2935-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, timo.teras@iki.fi, herbert@gondor.apana.org.au,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755775Ab0D1Qlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 12:41:49 -0400
In-Reply-To: <1272439222-2935-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 28 Apr 2010 15:20:22 +0800

> potential uninitialized variable num_xfrms
> 
> fix compiler warning: 'num_xfrms' may be used uninitialized in this function.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

We've all been seeing it for weeks too, but I honestly have
reservations about trying to simply pacify the compiler here.

The num_xfrms variable is only used in code paths that actually
initialize it's value.  The compiler just can't see this in the
control flow.

Check it if you don't believe me.
