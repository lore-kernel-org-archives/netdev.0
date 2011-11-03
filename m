From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Thu, 3 Nov 2011 13:58:51 -0500
Message-ID: <20111103135851.2229247682ec040d653479e1@freescale.com>
References: <1319360590.6180.75.camel@edumazet-laptop>
	<20111024.030203.404195331212003955.davem@davemloft.net>
	<20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
	<20111101.203430.110242050755204948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <stable@kernel.org>, <eric.dumazet@gmail.com>,
	<zheng.z.yan@intel.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:20473
	"EHLO DB3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933865Ab1KCS7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 14:59:52 -0400
In-Reply-To: <20111101.203430.110242050755204948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Nov 2011 20:34:30 -0400
David Miller <davem@davemloft.net> wrote:

> From: Kim Phillips <kim.phillips@freescale.com>
> Date: Tue, 1 Nov 2011 18:50:22 -0500
> 
> > -stable maintainers, please consider the following two upstream
> > commits for inclusion in upcoming v3.0.x [1] stable releases:
> 
> I submit networking stable fixes as needed, so please make such
> requests to me.
> 
> I haven't submitted this change yet because I want it to sit a bit
> longer in Linus's tree to make sure there aren't any unwanted
> side-effects.

I see b732339 (ipv4: fix ipsec forward performance regression) has
been added to the 3.0- and 3.1-stable trees.

b732339 increases IPSec fwding performance from 0.2kpps to ~3.5kpps.

However, adding upstream commit aa1c366 (net: Handle different key
sizes between address families in flow cache) brings performance
back up to 2.6.38 levels, i.e., ~44kpps.

So can aa1c366 also be queued to the v2.6.39 and v3.0 stable
trees?

Thanks,

Kim
