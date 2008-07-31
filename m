From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 10:36:31 -0500
Message-ID: <1217518591.3657.27.camel@calx>
References: <20080730.145727.07367670.davem@davemloft.net>
	 <20080730151316.a4d76fe9.akpm@linux-foundation.org>
	 <1217500776.3454.136.camel@pmac.infradead.org>
	 <20080731.034737.154058020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, thomas.petazzoni@free-electrons.com,
	shemminger@vyatta.com, jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:60635 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbYGaPja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 11:39:30 -0400
In-Reply-To: <20080731.034737.154058020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-31 at 03:47 -0700, David Miller wrote:
> I especially appreciate that you still haven't accepted the plain fact
> that CONFIG_ETHTOOL needs to be selected by CONFIG_INET.

So far the following features have been mentioned as being critically
dependent on ethtool:

- bridging
- bonding
- LRO
- netfilter (really?)
- IPv6 (really?)

And yet every single one of these is currently a config option, so your
above statement is still looking awfully dubious. At this point I'd
suggest that you've painted yourself into a corner where all these
options must also actually be mandatory, but I'm afraid you might
secretly want to do that anyway.

> I definitely see the next consequence of the CONFIG_ETHTOOL stuff, and
> that's a set of ifdef'ola in all the drivers to config out the
> per-driver ethtool support code.

If someone shows up with such a patch for a Xylinx or ARM SOC device,
you probably should take it. If the patch is instead for a 10Gb PCIe
device, I suggest you don't. (At least not until that sort of thing
becomes standard embedded kit.)

-- 
Mathematics is the supreme nostalgia of our time.

