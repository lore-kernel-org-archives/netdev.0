From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 14:37:01 -0700 (PDT)
Message-ID: <20061027.143701.85411558.davem@davemloft.net>
References: <20061027103016.3e8514d7@freekitty>
	<20061027.141749.41635827.davem@davemloft.net>
	<20061027142402.07a47f3f@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9608
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752507AbWJ0VhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 17:37:00 -0400
To: shemminger@osdl.org
In-Reply-To: <20061027142402.07a47f3f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 Oct 2006 14:24:02 -0700

> Only some (very few) have any bad consequences. So the typical
> distribution should be able to switch with most available for everyone,
> and only a few needing special privileges.

I would strongly disagree as we've had several OOPS'er class bugs in
the less frequently used algorithms.

I stand by my position that an administrator's wish to do this is
quite valid.

It's bad enough that people are all over us for the default algorithm
we have choosen, so it'd be extremely irresponsible and even worse if
we allowed users to select any of the other "research" algorithms for
their TCP connections by default just because those modules happened
to be configured into the kernel.

This userspace convenience argument holds zero water.

Provide a way for the administrator to control the situation fully,
and choose a sane default which errs on the side of caution for the
sake of internet stability.
