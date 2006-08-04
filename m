From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 23:23:49 -0400
Message-ID: <20060804032348.GA16313@thunk.org>
References: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au> <1154630207.3117.17.camel@rh4> <20060803201741.GA7894@thunk.org> <20060803.144845.66061203.davem@davemloft.net> <1154647699.3117.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:59095 "EHLO thunker.thunk.org")
	by vger.kernel.org with ESMTP id S1751420AbWHDDY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 23:24:27 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1154647699.3117.26.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 04:28:19PM -0700, Michael Chan wrote:
> True.  But they also have ASF enabled which requires tg3_timer() to send
> the heartbeat periodically.  If the heartbeat is late, ASF may reset the
> chip believing that the system has crashed.

Parden me for asking a dumb question, but what's being accomplished by
resetting the chip if the system has crashed?  Why not reset the chip
when the system reboots and it sees the PCI bus reset?  I guess I'm
missing the purpose of the ASF heartbeat; why does the networking chip
need a chip-specific watchdog?

						- Ted
