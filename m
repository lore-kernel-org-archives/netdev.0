From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix incorrect prototype for ipxrtr_route_packet()
Date: Thu, 17 May 2007 20:03:57 -0700 (PDT)
Message-ID: <20070517.200357.112621854.davem@davemloft.net>
References: <1179398893.2859.479.camel@shinybook.infradead.org>
	<20070517152746.8bd3ea07.akpm@linux-foundation.org>
	<1179452912.2859.521.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756381AbXERDDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 23:03:55 -0400
In-Reply-To: <1179452912.2859.521.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 18 May 2007 09:48:32 +0800

> On Thu, 2007-05-17 at 15:27 -0700, Andrew Morton wrote:
> > If only we could find some way in which all callers of a function as
> > well as its definition can see the same declaration? 
> 
> Well, building with --combine helps. :)
> 
> Admittedly it doesn't necessarily catch _all_ callers -- only those
> which we actually compile together. That does cover _most_ of the times
> we do crap like this without a prototype in a header file though, I
> suspect.
> 
> As Geert points out, sparse can warn about non-static functions which
> aren't prototyped; if we start getting anal about that, it might help.

I think it might be useful to be able to optionally to a --combine
build on the whole tree with like allyeconfig or something crazy like
that.  Just as a once-in-a-while thing to catch declaration mismatch
and other similar issues.

