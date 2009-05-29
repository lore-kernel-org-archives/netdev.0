From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug
 counter for non-debug configurations
Date: Thu, 28 May 2009 17:04:54 -0700 (PDT)
Message-ID: <20090528.170454.04735753.davem@davemloft.net>
References: <1243423017.16597.143.camel@deadeye>
	<20090527.135211.44614815.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F44CF8060@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbZE2AEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 20:04:54 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F44CF8060@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Thu, 28 May 2009 17:01:17 -0700

> The counter didn't really have much use other than in our early
> validation work to make certain the silicon was working as
> documented.  If it stays it isn't too big a concern I just figured
> it might be nice to remove it since igb is a multiqueue driver and
> having a global counter can cause some cache thrash on multicore
> systems.

If it really is just a silicon validation thing, then given the
multiqueue concerns it's probably best to just remove it
unconditionaly.
