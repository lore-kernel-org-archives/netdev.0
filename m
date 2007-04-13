From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Fri, 13 Apr 2007 16:19:50 -0700 (PDT)
Message-ID: <20070413.161950.26975931.davem@davemloft.net>
References: <20070411075602.GA17635@gondor.apana.org.au>
	<1176293751.14322.14.camel@localhost.localdomain>
	<20070411122317.GA21159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, jgarzik@pobox.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030882AbXDMXTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 19:19:50 -0400
In-Reply-To: <20070411122317.GA21159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 11 Apr 2007 22:23:17 +1000

> On Wed, Apr 11, 2007 at 10:15:51PM +1000, Rusty Russell wrote:
> > 
> > Actually, I did this precisely because I really didn't want to start
> > exposing bogus stats in /proc/net/dev.  An audit might clarify if this
> > is an actual issue.
> 
> Fair enough.  Still returning zeros when get_stats isn't available
> would seem safe enough.  I wasn't able to find any drivers which
> didn't have get_stats.

Given this, I'll drop Herbert's patch for now.

Let me know if I should apply something, in fact send it to me :)
