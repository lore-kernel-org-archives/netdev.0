From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 12:06:40 -0800 (PST)
Message-ID: <20070213.120640.18311028.davem@davemloft.net>
References: <20070212.145351.35661569.davem@davemloft.net>
	<20070213095613.GR25760@galon.ev-en.org>
	<649aecc70702130849s6f70bf37y1f8177060d433ce0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: sangtae.ha@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750913AbXBMUGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:06:42 -0500
In-Reply-To: <649aecc70702130849s6f70bf37y1f8177060d433ce0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "SANGTAE HA" <sangtae.ha@gmail.com>
Date: Tue, 13 Feb 2007 11:49:47 -0500

> I don't care what algorithm is default in kernel, however, it is not
> appropriate to get back to Reno. As Windows decided to go with
> "Compound TCP", why we want to back to 80's algorithm?

I want to re-emphasize this, in BIG BOLD LETTERS, that going back to
Reno is totally unacceptable recommendation to anyone in the current
internet environment.

In fact, it's a cop out to tell people they should use Reno instead
of one of the modern algorithms that can handle high BDP paths.

> What is criteria for "untested"?  Who judges that this algorithm is
> fully tested and is ready to use?

This is another excellent point.

Right now, in the end, the people who decide this are roughly
Stephen and myself.  So we do need to read the papers (we did),
think about the algorithm, and figure out what's best for Linux.
And that means balancing each possibility with each reasonable
alternative, and Reno is NOT a reasonable alternative.

And right now what's best for Linux, from our perspective, is a
default of CUBIC.

> Then, what do you want to make a default? You want to get back to
> BIC? or Reno?

Baruch has already stated that he recommends people to use Reno.
