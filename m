From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use default 32768-61000 outgoing port range in all
 cases
Date: Thu, 31 May 2007 15:43:47 -0700 (PDT)
Message-ID: <20070531.154347.24896889.davem@davemloft.net>
References: <20070515155054.394f4032@chirp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mark@glines.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44415
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750978AbXEaWne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 18:43:34 -0400
In-Reply-To: <20070515155054.394f4032@chirp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Glines <mark@glines.org>
Date: Tue, 15 May 2007 15:50:54 -0700

> I noticed I had chopped off a whole comment, when I meant to only remove
> part of it.  So I've fixed that.
> 
> This is a reissued use-high-ports-for-local-stuff.diff, with a comment
> fix.  Does anyone have a problem with this patch in its current form?
> Any chance of applying it?
> 
> This diff changes the default port range used for outgoing connections,
> from "use 32768-61000 in most cases, but use N-4999 on small boxes
> (where N is a multiple of 1024, depending on just *how* small the box
> is)" to just "use 32768-61000 in all cases".
> 
> I don't believe there are any drawbacks to this change, and it keeps
> outgoing connection ports farther away from the mess of IANA-registered
> ports.
> 
> Signed-off-by: Mark Glines <mark@glines.org>

Sorry for taking forever to wrap my brain around this, I think your
patch is the way to go and I will merge it.

The code was trying to match the allowed port range with the sizing
of the bind hash table, which is hashed by local port number.  But
even considering that I think it's OK to use the full range by
default, always.

Thanks a lot.
