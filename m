From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 16:02:02 -0700 (PDT)
Message-ID: <20070530.160202.48808347.davem@davemloft.net>
References: <20070530221039.GJ11166@waste.org>
	<20070530.152939.21591222.davem@davemloft.net>
	<20070530223612.GR11115@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, venkatesh.pallipadi@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56067
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751676AbXE3XBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 19:01:49 -0400
In-Reply-To: <20070530223612.GR11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 30 May 2007 17:36:12 -0500

> On Wed, May 30, 2007 at 03:29:39PM -0700, David Miller wrote:
> > From: Matt Mackall <mpm@selenic.com>
> > Date: Wed, 30 May 2007 17:10:39 -0500
> > 
> > > Are you agreeing that "it seems wasteful to add per-packet overhead"?
> > > This patch is not doing that.
> > 
> > Yes, and I know that :-)
> 
> Is there a real reason for watchdog_timeo to be all over the map?

In theory it's a hardware implementation and link speed specific value,
in reality nearly everyone just copies values from other drivers.

