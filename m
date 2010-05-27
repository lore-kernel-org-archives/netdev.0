From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 20:56:56 +0200
Message-ID: <20100527185656.GD6800@basil.fritz.box>
References: <20100526212745.GC24615@basil.fritz.box> <20100526.151014.70204145.davem@davemloft.net> <20100526231512.GD2684@nuttenaction> <20100526.200443.232751390.davem@davemloft.net> <20100527070827.GB2728@nuttenaction> <AANLkTime8wfTLfdNMAx_HYr6XO0DiO12r5FVdGBjVNwT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42202 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759544Ab0E0S46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 14:56:58 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTime8wfTLfdNMAx_HYr6XO0DiO12r5FVdGBjVNwT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It would be better, by almost any perspective, to rein in the number
> of connections servers are allowing clients to open.  However this
> isn't going to happen if this means increase latency for end users,
> there's is no competitive rationale for servers to do that.  That's
> where a primary motivation of this patch becomes evident.  Instead of
> a server allowing 6 connections from a client, for instance, it could
> allow just one connection but with a initial congestion window equal
> to the aggregate of the 6 connections.  This reduces connections and

I thought the point was to avoid cwnd inflation by multiple connections?
Now you're saying you actually want larger cwnds? 

If you simply want larger CWNDs the easiest is to bump up the
define in your local build.

But that cannot be done by default obviously.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
