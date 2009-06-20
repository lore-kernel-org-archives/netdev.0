From: David Miller <davem@davemloft.net>
Subject: Re: TCP Persist Timer DoS
Date: Sat, 20 Jun 2009 01:05:14 -0700 (PDT)
Message-ID: <20090620.010514.46602476.davem@davemloft.net>
References: <20090619223106.GJ29140@mail.oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joel.Becker@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752180AbZFTIFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 04:05:10 -0400
In-Reply-To: <20090619223106.GJ29140@mail.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joel Becker <Joel.Becker@oracle.com>
Date: Fri, 19 Jun 2009 15:31:06 -0700

> Hey Netfolk,
> 	I have to assume you've seen
> http://www.phrack.org/issues.html?issue=66&id=9&mode=txt.  Does anyone
> have a plan or opinion on the DoS?  A way to mitigate it, a -EDONTCARE
> opinion, anything?

This is just like every other "DoS" out there where the attacker has
to reveal it's IP identity to accomplish the attack, in that it is
trivial to protect using netfilter by limiting the number of
connections a host can make with your system.

There are thousands of ways to open up a ton of TCP connections and
have them sit in a dormant state infinitely.

Nothing is really new here.

I noticed some amusing things in the threads discussing this: "Is it
just me or can pretty much every web site in the world get turned off
now?"

Ok, Chicken Little, the sky is falling.
