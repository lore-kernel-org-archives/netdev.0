From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sun, 10 Feb 2013 00:08:06 +0100
Message-ID: <20130209230806.GA16640@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@wide.ad.jp>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54641 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756349Ab3BIXIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 18:08:07 -0500
Content-Disposition: inline
In-Reply-To: <5116595E.2080601@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 09, 2013 at 11:12:46PM +0900, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> Hannes Frederic Sowa wrote:
> > On Wed, Feb 06, 2013 at 05:54:15PM +0100, Hannes Frederic Sowa wrote:
> >> On Thu, Feb 07, 2013 at 12:24:14AM +0900, YOSHIFUJI Hideaki wrote:
> >>> NAK.  I think we should select routes via loopback device here.
> >>
> >> Will try your idea, thanks.
> > 
> > Does this patch look reasonable? Btw. i am pleased to see this kind of
> > things work out as expected most of the time (addrtype checking etc. all
> > in place). :)
> > 
> 
> Well, I rethink of what "interface-local" means.
> 
> It seems applications will join ff01::/16%eth0 instead of ff01::/16%lo.
> If so, your original patch seems better.  My bad, sorry.

No problem, will do. I have not checked carefully, but this would mean we have
to do changes to glibc to have a correct behaving getaddrinfo?

> Would you update original one, with minor modification that defers
> kfree_skb() after incrementing MIB, please?

Yes. Will send the patch tomorrow at the latest.
> 
> If you think we should join ff01::{1,2} by default, you can send another
> patch for it.  (BTW, why don't we join ff05::2, then? ;-))

Ok, I'll split it up. You are right about ff05::2, seems like the right thing
to do, somehow. I hope this won't impact any multicast routing daemons. 

Thanks,

  Hannes
