From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 09:46:37 -0700
Message-ID: <1154623598.19547.52.camel@c-67-188-28-158.hsd1.ca.comcast.net>
References: <20060803075704.GC27835@thunk.org>
	 <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au>
	 <20060803163204.GB20603@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:48586 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S964856AbWHCQql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 12:46:41 -0400
To: Theodore Tso <tytso@mit.edu>
In-Reply-To: <20060803163204.GB20603@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 12:32 -0400, Theodore Tso wrote:

> This only shows up with the real-time kernel where timer softirq's run
> in their own processes, and a high priority process preempts the timer
> softirq.  I don't really consider this a networking bug, or even
> driver bug, although it does seem unfortunate that Broadcom hardware
> locks up and goes unresponsive if the OS doesn't tickle it every tenth
> of a second or so.  (Definitely a bad idea if the tg3 gets used on any
> laptops, from a power usage perspective.)  But that seems like a
> (lame) hardware bug, not a driver bug....

There is some form of priority inheritance on the timer softirq. It said
in the patch header that the right fix was for the timer softirq to
change priorities. Which Real Time patch are you using? Or is the
current system not sufficient ?

Daniel



