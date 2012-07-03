From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 02 Jul 2012 17:15:07 -0700 (PDT)
Message-ID: <20120702.171507.1288066003825644221.davem@davemloft.net>
References: <4FF153F0.8080707@mellanox.com>
	<20120702.013445.1273332212099485403.davem@davemloft.net>
	<1341252445.2590.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@kernel.org, yevgenyp@mellanox.com,
	oren@mellanox.com, netdev@vger.kernel.org, hadarh@mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab2GCAPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 20:15:08 -0400
In-Reply-To: <1341252445.2590.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 2 Jul 2012 19:07:25 +0100

> But there may not be enough commonality to define a non- vendor-specific
> API.  And ethtool really isn't a good way to expose parameters that are
> per-controller rather than per-net-device, particularly if changing them
> may disrupt all running net devices on that controller and not just the
> one used to invoke SIOCETHTOOL.

I fundamentally disagree with you.

Are you really saying that it's OK for every damn vendor to define
their own magic knob to control stuff like this?  Surely you're not.
