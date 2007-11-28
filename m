From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 28 Nov 2007 12:27:49 +1100
Message-ID: <200711281227.50136.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711271549.37670.rusty@rustcorp.com.au> <1196141742.9876.49.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41083 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754708AbXK1C3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 21:29:39 -0500
In-Reply-To: <1196141742.9876.49.camel@trinity.ogc.int>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 November 2007 16:35:42 Tom Tucker wrote:
> On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
> Explicitly documenting what comprises the kernel API (external,
> supported) and what comprises the kernel implementation (internal, not
> supported).

But the former is currently an empty set.

> - making it obvious to developers when they are binding their
> implementation to a particular kernel release

See, there's your problem.  All interfaces can, and will, change.  You're 
always binding yourself to a particular release.

So you're not proposing we mark what's not stable, you're arguing that we 
create a subset which is stable.

That's an argument we're not (yet) having.

Cheers,
Rusty.
