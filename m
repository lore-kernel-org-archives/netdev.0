From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix IBM EMAC driver after rename.
Date: Thu, 18 Aug 2011 20:44:00 -0700 (PDT)
Message-ID: <20110818.204400.1898706003071593302.davem@davemloft.net>
References: <20110818061354.GD19739@ozlabs.org>
	<20110817.234947.611559275017926008.davem@davemloft.net>
	<20110819012558.GF19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: tony@bakeyournoodle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab1HSDqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 23:46:05 -0400
In-Reply-To: <20110819012558.GF19739@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Breeds <tony@bakeyournoodle.com>
Date: Fri, 19 Aug 2011 11:25:58 +1000

> On Wed, Aug 17, 2011 at 11:49:47PM -0700, David Miller wrote:
> 
>> You also need to select the dependencies, such as "ETHERNET" for this
>> to be correct.
> 
> These symbols are turned on in the appropriate defconfig.  It's ben done this
> was so that you can (for example) build canyonlands with or without the EMAC
> driver but if you de enable the EMAC driver we ensure (via the selects) that
> you get all the components you need.

Don't do this :-(  When you reply to me as your new version of the patch
it craps up the commit message.

Always make a fresh, new, patch posting with a clean full commit message
without any non-essential material included.

I'm not applying this, because I'm pretty sick and tired of having to
edit up people's patch postings when they do stuff like this.
