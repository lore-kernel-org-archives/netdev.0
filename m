From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC iproute2] sch_red: TC_RED_HARDDROP
Date: Wed, 30 Nov 2011 18:29:10 -0500
Message-ID: <20111130232910.GC11942@canuck.infradead.org>
References: <1322684749.2602.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39555 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab1K3X3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 18:29:12 -0500
Content-Disposition: inline
In-Reply-To: <1322684749.2602.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 09:25:49PM +0100, Eric Dumazet wrote:
> In 2005, TC_RED_HARDDROP kernel support was added to RED and GRED
> (commit bdc450a0bb1 [PKT_SCHED]: (G)RED: Introduce hard dropping), but
> current iproute2 doesnt have user land support.
> 
> Is there some patch waiting somewhere, or should we :
> 
> - Remove kernel support, since nobody uses it.
> 
> - Add iproute2 support.

I used it in a project which configured the GRED qdisc directly from
the application.

I thought I added iproute2 support back then but obviously must have
missed it or the patch got lost. I'll send a patch to Stephen.
