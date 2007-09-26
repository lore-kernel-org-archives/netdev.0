From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and
 print_ipv6
Date: Tue, 25 Sep 2007 22:11:15 -0700 (PDT)
Message-ID: <20070925.221115.26296263.davem@davemloft.net>
References: <1190271211.26101.91.camel@localhost>
	<20070925.192917.21908774.davem@davemloft.net>
	<1190781398.17052.18.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbXIZFLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 01:11:16 -0400
In-Reply-To: <1190781398.17052.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 25 Sep 2007 21:36:38 -0700

> On Tue, 2007-09-25 at 19:29 -0700, David Miller wrote:
> > I'm going to hold on this for now, there is no universal
> > agreement that this is something we want to do and I'd
> > like to take care of getting the more certain stuff into
> > net-2.6.24 before "iffy" bits like this one.
> 
> Here's an argument for inclusion:
> 
> defconfig without patches:

Sure, but this ignores certain things that text/data/bss
size don't show you.

For one thing, stack frames might now be larger in the
functions where the new variables get added, even if they
aren't used to print out the debugging message.  And that
could have negative performance implications.

Nothing is every black and white, everything is gray :-)
