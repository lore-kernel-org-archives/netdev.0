From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Fri, 28 Mar 2014 17:12:53 -0400 (EDT)
Message-ID: <20140328.171253.1863144825039621848.davem@davemloft.net>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
	<20140327.145336.1708122219432567015.davem@davemloft.net>
	<1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: VenkatKumar.Duvvuru@Emulex.Com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbaC1VM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:12:56 -0400
In-Reply-To: <1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 28 Mar 2014 01:39:30 +0000

> By grouping the key and hash together, with some reserved fields (which
> the setter should initially require to be equal to zero), it should be
> possible to fill in support for numbered RSS contexts later without yet
> another new structure and operations.

If that is the case, why don't we add from the start a "u32 rss_context;"
field that has to be set to zero for now?
