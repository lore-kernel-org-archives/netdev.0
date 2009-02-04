From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [RFC PATCH 09/12] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 06:29:52 -0800
Message-ID: <1233757792.15119.58.camel@desktop>
References: <1229352899-31330-1-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-2-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-3-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-4-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-5-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-6-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-7-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-8-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-9-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-10-git-send-email-patrick.ohly@intel.com>
	 <1229358410.8699.13.camel@jstultz-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, linux-api@vger.kernel.org
To: John Stultz <johnstul@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:35198 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbZBDO3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 09:29:54 -0500
In-Reply-To: <1229358410.8699.13.camel@jstultz-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-15 at 08:26 -0800, John Stultz wrote:

> Nice. The cyclecounter struct can work as a good base that I can shift
> the clocksource bits over to as I clean that up.
> 
> We will probably want to split this out down the road, but for now its
> small enough and related enough that I think its fine in the
> clocksource.h/c.
> 
> Also since Magnus has been working on it, does enable/disable accessors
> in the cyclecounter struct make sense for your hardware as well?
> 
> Also the corner cases on overflows (how we manage the state, should
> reads be deferred for too long) will need to be addressed, but I guess
> we can solve that when it becomes an issue. Just to be clear: none of
> the hardware you're submitting this round has wrapping issues? Or is
> that not the case?

Why wouldn't this just use a clocksource directly and not register it
with the timekeeping? The cyclecounter is just a subset of the
clocksource ..

Daniel

