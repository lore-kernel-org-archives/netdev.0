From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 17:23:21 +0200
Message-ID: <20130715172321.61e8c237@skate>
References: <20130704173552.GA23370@1wt.eu>
	<20130715163408.4064699f@skate>
	<20130715151240.GD6844@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:58082 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932700Ab3GOPYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:24:51 -0400
In-Reply-To: <20130715151240.GD6844@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Mon, 15 Jul 2013 17:12:40 +0200, Willy Tarreau wrote:

> > 3.11-rc1 is now out. Do you intend to resend an updated version of your
> > patches, according to the discussions we had?
> 
> Yes I'll do. This week-end I have tried to pre-compute the frag_size.
> The performance did not change, nor the driver size, but the code is
> cleaner and more readable (in my opinion).

Ok.

> I have noticed your recent patches to support big-endian, and since
> we risk to get conflicts by touching similar areas, I guess you'll
> prefer to have a clean patch series that applies well.

The big-endian support is pretty light in terms of driver changes, so
if there are conflicts, they should be easy to solve.

> I'm still checking a little bit what can be easily improved (if any)
> and will resend.

Excellent, thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
