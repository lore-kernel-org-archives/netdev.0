From: Bill Fink <billfink@mindspring.com>
Subject: Re: Channel bonding with e1000
Date: Fri, 5 Sep 2008 21:36:06 -0400
Message-ID: <20080905213606.0b4e246a.billfink@mindspring.com>
References: <48C0EF8A.9070103@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:37234
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbYIFBgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 21:36:13 -0400
In-Reply-To: <48C0EF8A.9070103@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Sep 2008, Carsten Aulbert wrote:

> I have a brief problem and would ask for a little assistance:
> 
> On a few data servers we intend to do channel bonding. The boxes have
> two NICs on the motherboard and two extra ones on an expansion card:
> 
> 04:00.0 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
> Controller Copper (rev 01)
> 04:00.1 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
> Controller Copper (rev 01)
> 05:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)
> 05:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)
> 
> My simple question would be: Does it matter which two ports I can use to
> channel together when using in a set-up with MTU=9000?

I don't know the specifics of your case, but sometimes the builtin
NICs on the motherboard may not have as much memory buffering as
the better addon NICs.

Also check the respective PCI buses of the onboard NICs versus the
addon NICs.  If one is PCI versus PCI-X or PCI-E, or are different
speeds or bus widths, this can obviously significantly impact
performance, especially when doing bonding.

Of course nothing beats some quick performance tests to determine
which is the better performing combination.

						-Bill
