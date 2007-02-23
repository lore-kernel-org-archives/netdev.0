From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Fri, 23 Feb 2007 22:16:57 +0000
Message-ID: <20070223221657.GA10153@infradead.org>
References: <20070124225850.GU17836@stusta.de> <45B8D5E8.1090308@ericsson.com> <20070223180612.GE12392@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>, per.liden@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60647 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933236AbXBWWSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 17:18:08 -0500
Content-Disposition: inline
In-Reply-To: <20070223180612.GE12392@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 23, 2007 at 07:06:12PM +0100, Adrian Bunk wrote:
> > >My impression is that most of this might have users that are not yet 
> > >submitted for inclusion in the kernel - one year after TIPC was merged.
> > > 
> > >
> > Not quite. The exported symbols belong to a public API for driver 
> > programmers.
> > We know about several users of this API, and there will be more, but I 
> > don't think
> > any of them are aspiring to have their code be included in the kernel.
> >...
> 
> Why not?
> 
> The goal is to get as many drivers as possible included in the kernel.

If we don't have any planned in-tree users for tipc we should simply drop
tipc from the kernel entirely.  No point to make our maintaince work harder
for out of tree freeloaders.
