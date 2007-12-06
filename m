From: David Miller <davem@davemloft.net>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 06 Dec 2007 02:20:58 -0800 (PST)
Message-ID: <20071206.022058.153600766.davem@davemloft.net>
References: <20071205.053031.87154402.davem@davemloft.net>
	<1196873587.10819.30.camel@localhost>
	<20071205163338.50aff45d@shemminger-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751625AbXLFKVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 05:21:01 -0500
In-Reply-To: <20071205163338.50aff45d@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 5 Dec 2007 16:33:38 -0500

> On Wed, 05 Dec 2007 08:53:07 -0800
> Joe Perches <joe@perches.com> wrote:
> 
> > > it occurred to me that we might want to do something
> > > like a state change event generator.
> > 
> > This could be a basis for an interesting TCP
> > performance tester.
> 
> That is what tcpprobe does but it isn't detailed enough to address SACK
> issues.

Indeed, this could be done via the jprobe there.

Silly me I didn't do this in the implementation I whipped
up, which I'll likely correct.
