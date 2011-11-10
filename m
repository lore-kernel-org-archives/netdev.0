From: David Miller <davem@davemloft.net>
Subject: Re: dst->obsolete has become pointless
Date: Wed, 09 Nov 2011 19:24:27 -0500 (EST)
Message-ID: <20111109.192427.661860445333469011.davem@davemloft.net>
References: <1320842948.6923.3.camel@Joe-Laptop>
	<20111109.142044.1307358041881082836.davem@davemloft.net>
	<1320882969.6923.29.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214Ab1KJAYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 19:24:48 -0500
In-Reply-To: <1320882969.6923.29.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 09 Nov 2011 15:56:09 -0800

> As far as I know, other than being large enough to
> store a 1 and 0, it's implementation defined.
> 
> Just like an unsigned short.
> 
> I _believe_ gcc uses unsigned char width for
> _Bool in all normal cases though.

We can only use it in this scenerio if it universally
uses the same type.  This is due to the by-hand layout
of the rest of the structure such that __refcnt ends
up on a different cache line.
