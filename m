From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 17:12:40 +0200
Message-ID: <20130715151240.GD6844@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130715163408.4064699f@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34650 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756020Ab3GOPMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jul 2013 11:12:43 -0400
Content-Disposition: inline
In-Reply-To: <20130715163408.4064699f@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Mon, Jul 15, 2013 at 04:34:08PM +0200, Thomas Petazzoni wrote:
> Dear Willy Tarreau,
> 
> On Thu, 4 Jul 2013 19:35:52 +0200, Willy Tarreau wrote:
> > From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Sat, 15 Jun 2013 23:25:15 +0200
> > Subject: [PATCH] net: convert mvneta to build_skb()
> > 
> > We store the frag_size in the mvneta_port struct. In practice we'd need
> > a single bit to know how to free the data, but since we need the size to
> > call build_skb() anyway, let's store the full size.
> > 
> > With this patch, I observed a reproducible 2% performance improvement on
> > HTTP-based benchmarks.
> > 
> > Signed-off-by: Willy Tarreau <w@1wt.eu>
> 
> 3.11-rc1 is now out. Do you intend to resend an updated version of your
> patches, according to the discussions we had?

Yes I'll do. This week-end I have tried to pre-compute the frag_size.
The performance did not change, nor the driver size, but the code is
cleaner and more readable (in my opinion).

I have noticed your recent patches to support big-endian, and since
we risk to get conflicts by touching similar areas, I guess you'll
prefer to have a clean patch series that applies well.

I'm still checking a little bit what can be easily improved (if any)
and will resend.

Best regards,
Willy
