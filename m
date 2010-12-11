From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Sat, 11 Dec 2010 14:39:45 +0900
Message-ID: <20101211053945.GA2101@verge.net.au>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
 <1292042278.3136.14.camel@localhost>
 <20101211050447.GC32453@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34896 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab0LKFju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:39:50 -0500
Content-Disposition: inline
In-Reply-To: <20101211050447.GC32453@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 02:04:47PM +0900, Simon Horman wrote:
> On Sat, Dec 11, 2010 at 04:37:58AM +0000, Ben Hutchings wrote:
> > On Sat, 2010-12-11 at 13:13 +0900, Simon Horman wrote:
> > > Early orphaning is an optimisation which avoids unnecessary cache misses by
> > > orphaning an skb just before it is handed to a device for transmit thus
> > > avoiding the case where the orphaning occurs on a different CPU.
> > > 
> > > In the case of bonded devices this has the unfortunate side-effect of
> > > breaking down flow control allowing a socket to send UDP packets as fast as
> > > the CPU will allow. This is particularly undesirable in virtualised
> > > network environments.
> > > 
> > > This patch introduces ethtool control of early orphaning.
> > > It remains on by default by it now may be disabled on a per-interface basis.
> > > 
> > > I have implemented this as a generic flag.
> > > As it seems to be the first generic flag that requires
> > > no driver awareness I also supplied a default flag handler.
> > > I am unsure if any aspect of this approach is acceptable.
> > 
> > I'm not convinced that this belongs in the ethtool API.  It doesn't seem
> > to have anything to do with hardware or driver behaviour.  The flag
> > belongs in priv_flags, not features.
> 
> Ok, I have no objection to it going in priv_flags so long
> as it can be exposed to user-space in some sensible fashion.
> Do you have any thoughts on how best to achieve that?

Sorry, I realise that was a pretty silly question
as I now see ETHTOOL_GPFLAGS and ETHTOOL_SPFLAGS.

