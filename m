From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Sun, 12 Apr 2009 20:45:05 -0600
Message-ID: <20090413024505.GC13090@lackof.org>
References: <20090328024754.GA16554@bombadil.infradead.org> <20090328032332.GA22353@bombadil.infradead.org> <20090329053513.GD19602@colo.lackof.org> <20090328.235931.45430524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, error27@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:42289 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbZDMCpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 22:45:07 -0400
Content-Disposition: inline
In-Reply-To: <20090328.235931.45430524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:59:31PM -0700, David Miller wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> Date: Sat, 28 Mar 2009 23:35:13 -0600
> 
> > On Fri, Mar 27, 2009 at 11:23:32PM -0400, Kyle McMartin wrote:
> > > On Fri, Mar 27, 2009 at 10:47:54PM -0400, Kyle McMartin wrote:
> > > > > I don't know if the right fix is to return like this patch does or to set 
> > > > > skb = rxptr->rx_skb_ptr again.
> > > > > 
> > > > 
> > > > Ick... that's a good catch. I'll have to think about this.
> > > > 
> > > 
> > > I think this is alright, it at least keeps the original intent of the
> > > code. I don't pretend to have figured it out yet though.
> > > 
> > > I'll stare more at this Monday...
> > > 
> > > I guess the real question is does anyone still have one of these
> > > cards. I don't think I do, just the proper tulips. :/
> > 
> > Ditto. AFAIK, I only have tulips.
> > 
> > Patch below looks right to me. Clobbering the skb is certainly wrong.
> > 
> > Acked-by: Grant Grundler <grundler@parisc-linux.org>
> 
> It looks correct to me, can we get a proper submission with
> signoffs etc.?

Dave,
Is that something I have to do or the original submitter?
Was the "Acked-by" appropriate for me to provide (as maintainer)?
I can resubmit with Signed-off-by if that's what is expected.

thanks,
grant
