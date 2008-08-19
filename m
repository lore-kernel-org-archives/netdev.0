From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Kill qdisc rcu freeing...
Date: Mon, 18 Aug 2008 22:33:57 -0700 (PDT)
Message-ID: <20080818.223357.170917294.davem@davemloft.net>
References: <20080817.223435.193704624.davem@davemloft.net>
	<20080818120725.GB7393@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750967AbYHSFd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:33:57 -0400
In-Reply-To: <20080818120725.GB7393@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 12:07:25 +0000

> On Sun, Aug 17, 2008 at 10:34:35PM -0700, David Miller wrote:
> > 
> > Ok, I flipped the switch.  I've checked in the following to
> > net-2.6 and it seems to pass a bunch of smoke tests I just
> > did (flood pings while adding and deleting various qdisc
> > setups, etc.)
> > 
> > Jarek, I think we can possibly now revert that locking change
> > you had to make because destroy was outside of RTNL?
> 
> Yes, I think there are these two patches only to revert:
> 
> ----------
 ...
> commit d4766692e72422f3b0f0e9ac6773d92baad07d51
 ...
> ----------
 ...
> commit 1cfa26661a85549063e369e2b40275eeaa7b923c
 ...
> ----------
> 
> I guess, I don't need to send any patches, but let me know if I'm
> wrong.

Thanks, I've reverted both commits.
