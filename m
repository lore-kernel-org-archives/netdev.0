From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Fri, 28 Sep 2007 11:39:45 -0700
Message-ID: <20070928113945.389a6a70.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
	<20070921124409.7f3d122b.akpm@linux-foundation.org>
	<Pine.LNX.4.64N.0709241529570.22491@blysk.ds.pg.gda.pl>
	<20070924095559.c81f7061.akpm@linux-foundation.org>
	<Pine.LNX.4.64N.0709281628130.10439@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56591 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752867AbXI1Sko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:40:44 -0400
In-Reply-To: <Pine.LNX.4.64N.0709281628130.10439@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 17:23:00 +0100 (BST) "Maciej W. Rozycki" <macro@linux-mips.org> wrote:

> On Mon, 24 Sep 2007, Andrew Morton wrote:
> 
> > >  Well, this is against Jeff's netdev-2.6 tree which hopefully is not as 
> > > crufty as Linus's old mainline; if it is not possible to queue this change 
> > > for 2.6.25 or suchlike, then I will try to resubmit later.
> > 
> > Most of Jeff's netdev tree got dumped into Dave's net-2.6.24 tree.  That's
> > the one you want to be raising patches against for the next few weeks.
> 
>  OK, thanks for clarification.  Then both patches already submitted:
> 
> patch-netdev-2.6.23-rc6-20070920-sb1250-mac-typedef-9
> patch-netdev-2.6.23-rc6-20070920-sb1250-mac-29
> 
> apply cleanly to net-2.6.24 one on top of the other in this order.

<checks the netdev archives>

hm, I found a patch at the end of an email trail which is datestamped Sep
20 here which appears to match the first one you mentioned, but I'm having
trouble working out what patch subject your "sb1250-mac" maps onto.

This is why I make the patch filenames map directly from the patch titles,
so I end up with files like
optimize-x86-page-faults-like-all-other-achitectures-and-kill-notifier-cruft.patch.
 Verbose, but it reduces confusion and mistakes.

>  I can resubmit them

That's always a good choice.  Patches which are dangling at the end of an email
discussion often don't get merged: it is unclear to the receiveing party that
the discussion has terminated, and I'm never terribly confident in the testing
level of a patch which obviously got modified two minutes before it was sent.

> -- where?  netdev?  As I say I am fine with 2.6.25 as 
> the target.

jeff, netdev, me?  
