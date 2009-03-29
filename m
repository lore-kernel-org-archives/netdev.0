From: David Miller <davem@davemloft.net>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Sat, 28 Mar 2009 23:59:31 -0700 (PDT)
Message-ID: <20090328.235931.45430524.davem@davemloft.net>
References: <20090328024754.GA16554@bombadil.infradead.org>
	<20090328032332.GA22353@bombadil.infradead.org>
	<20090329053513.GD19602@colo.lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kyle@mcmartin.ca, netdev@vger.kernel.org, error27@gmail.com
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752434AbZC2G7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:59:43 -0400
In-Reply-To: <20090329053513.GD19602@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Sat, 28 Mar 2009 23:35:13 -0600

> On Fri, Mar 27, 2009 at 11:23:32PM -0400, Kyle McMartin wrote:
> > On Fri, Mar 27, 2009 at 10:47:54PM -0400, Kyle McMartin wrote:
> > > > I don't know if the right fix is to return like this patch does or to set 
> > > > skb = rxptr->rx_skb_ptr again.
> > > > 
> > > 
> > > Ick... that's a good catch. I'll have to think about this.
> > > 
> > 
> > I think this is alright, it at least keeps the original intent of the
> > code. I don't pretend to have figured it out yet though.
> > 
> > I'll stare more at this Monday...
> > 
> > I guess the real question is does anyone still have one of these
> > cards. I don't think I do, just the proper tulips. :/
> 
> Ditto. AFAIK, I only have tulips.
> 
> Patch below looks right to me. Clobbering the skb is certainly wrong.
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

It looks correct to me, can we get a proper submission with
signoffs etc.?
