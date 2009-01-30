From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:
 (sk_lock-AF_PACKET){--..}, at: [<c1279838>] sock_setsockopt+0x12b/0x4a4
Date: Fri, 30 Jan 2009 14:05:23 -0800 (PST)
Message-ID: <20090130.140523.57804123.davem@davemloft.net>
References: <20090130124947.GA6886@gondor.apana.org.au>
	<20090130135617.GA16106@ff.dom.local>
	<20090130220128.GA11381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, mmokrejs@ribosome.natur.cuni.cz,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, vegard.nossum@gmail.com,
	a.p.zijlstra@chello.nl
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752618AbZA3WFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:05:25 -0500
In-Reply-To: <20090130220128.GA11381@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 31 Jan 2009 09:01:28 +1100

> On Fri, Jan 30, 2009 at 01:56:17PM +0000, Jarek Poplawski wrote:
> >
> > > I resisted the temptation to create a new spin lock because the
> > > mmap path isn't exactly common.
> > 
> > So, Dave is stronger than the temptation...
> 
> Heh, that sentence should be removed from the description.

I might leave it in there for laughs :-)
