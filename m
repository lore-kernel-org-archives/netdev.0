From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 18:07:08 -0400
Message-ID: <4685828C.2000300@garzik.org>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org> <46857C08.4030303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60582 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129AbXF2WHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 18:07:16 -0400
In-Reply-To: <46857C08.4030303@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> That's why we want to introduce a second e1000 driver (named 
> differently, pick any name) that contains the new code base, 
> side-by-side into the kernel with the current e1000.

We do not want to introduce duplicate drivers for the same hardware.  We 
spend -years- before the old driver gets removed.  There are installer 
headaches with distros, with duplicate drivers.  User confusion. 
Problems abound, as past history shows.

I meant a new driver for ICH9 and later hardware, or whatever hardware 
boundary between new-driver and old-driver you wish to pick.

That way the new driver doesn't carry all the old baggage with it, and 
can go quietly into old age.


> This would allow everyone to fallback and compare the new and old code 
> instantly, for several kernel releases at least. After that period, we 
> can retire the old codebase.

No it takes -years- to kill duplicate drivers, when you consider all the 
transition effects.  That is what history shows us time and again.


> Given the size of the changes and the fact that this is an interal API 
> change that gigantically changes how e1000 internally works, there is 
> *no* way that we can introduce this change in any other way in my opinion.

The standard way to introduce big changes is to (a) do them, and then 
(b) plot the steps involved in the transition, and create those steps 
that lead us to the goal.

	Jeff


