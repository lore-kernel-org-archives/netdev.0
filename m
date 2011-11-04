From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Thu, 03 Nov 2011 22:43:29 -0400 (EDT)
Message-ID: <20111103.224329.2276058062630695656.davem@davemloft.net>
References: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
	<20111101.203430.110242050755204948.davem@davemloft.net>
	<20111103135851.2229247682ec040d653479e1@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, eric.dumazet@gmail.com,
	zheng.z.yan@intel.com, netdev@vger.kernel.org
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab1KDCnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 22:43:37 -0400
In-Reply-To: <20111103135851.2229247682ec040d653479e1@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Thu, 3 Nov 2011 13:58:51 -0500

> I see b732339 (ipv4: fix ipsec forward performance regression) has
> been added to the 3.0- and 3.1-stable trees.
> 
> b732339 increases IPSec fwding performance from 0.2kpps to ~3.5kpps.
> 
> However, adding upstream commit aa1c366 (net: Handle different key
> sizes between address families in flow cache) brings performance
> back up to 2.6.38 levels, i.e., ~44kpps.
> 
> So can aa1c366 also be queued to the v2.6.39 and v3.0 stable
> trees?

1) stable@kernel.org no longer exists and will just go into the bit
   bucket, it's now stable@vger.kernel.org

2) The patch in question doesn't apply cleanly to v3.0.8 -stable so
   if it's important to you you'll need to submit a backport.

3) 2.6.39 is no longer a maintained -stable kernel series.
