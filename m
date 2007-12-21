From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 01:36:42 -0800 (PST)
Message-ID: <20071221.013642.29817274.davem@davemloft.net>
References: <20071221030648.389669c4.billfink@mindspring.com>
	<20071221.012720.67812056.davem@davemloft.net>
	<20071221092927.GA32434@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, jheffner@psc.edu
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbXLUJgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:36:42 -0500
In-Reply-To: <20071221092927.GA32434@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 21 Dec 2007 17:29:27 +0800

> On Fri, Dec 21, 2007 at 01:27:20AM -0800, David Miller wrote:
> >
> > It's two shifts, and this gets scheduled along with the other
> > instructions on many cpus so it's effectively free.
> > 
> > I don't see why this is even worth mentioning and discussing.
> 
> I totally agree.  Two shifts are way better than a branch.

We take probably a thousand+ 100+ cycle cache misses in the TCP stack
on big window openning ACKs.

Instead of discussing ways to solve that huge performance killer we're
wanking about two friggin' integer shifts.

It's hilarious isn't it? :-)

