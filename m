From: David Miller <davem@davemloft.net>
Subject: Re: strange tcp behavior
Date: Sat, 04 Aug 2007 20:21:43 -0700 (PDT)
Message-ID: <20070804.202143.85411433.davem@davemloft.net>
References: <20070803082242.GA25582@2ka.mipt.ru>
	<20070803.141717.36925406.davem@davemloft.net>
	<20070804165151.GE14175@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754128AbXHEDVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2007 23:21:44 -0400
In-Reply-To: <20070804165151.GE14175@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 4 Aug 2007 20:51:51 +0400

> On Fri, Aug 03, 2007 at 02:17:17PM -0700, David Miller (davem@davemloft.net) wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Fri, 3 Aug 2007 12:22:42 +0400
> > 
> > > Maybe recvmsg should be changed too for symmetry?
> > 
> > I took a look at this, and it's not %100 trivial.
> > 
> > Let's do this later, and only sendmsg for now in order to
> > fix the bug in the stable branches.
> 
> I've tested your patch, besides there was an offset in one of hooks, 
> it works perfectly ok.
> 
> Feel free to add my ack, tested-by or whatever is needed for this :)
> Your patch fixes the problem.

It is already merged to Linus's tree long before you found a chance to
test it :-)  So it would be difficult for me to do so.

