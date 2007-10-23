From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 20:39:59 -0700
Message-ID: <1193110799.5132.48.camel@localhost>
References: <1193081779.5132.24.camel@localhost>
	 <20071022203052.23725719@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2276 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbXJWDzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 23:55:03 -0400
In-Reply-To: <20071022203052.23725719@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-22 at 20:30 -0700, Stephen Hemminger wrote:
> > Corrected fast code is:
> > 
> >         while (len--) {
> >                 sum += *data++;
> >                 sum <<= 1;
> >                 sum = (((sum & 0x10000) >> 16) + sum) & 0xffff;
> >         }
> > 
> > At least it is correct on the standalone random data test, and the
> > new code is 30% faster for the cached memory case (13.7 clks/byte vs 18 
> > clks/byte).
> Your code looks different...

Both are 16 bit rotate lefts.
Which looks clearer?

