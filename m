From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/5] net: Support ethtool ops for rx of errored
 frames.
Date: Sun, 19 Jun 2011 16:24:37 -0700 (PDT)
Message-ID: <20110619.162437.1293948476324391637.davem@davemloft.net>
References: <4DFE57DA.8090404@candelatech.com>
	<20110619224800.GA2861@electric-eye.fr.zoreil.com>
	<4DFE832C.7000100@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab1FSXYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:24:41 -0400
In-Reply-To: <4DFE832C.7000100@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Sun, 19 Jun 2011 16:15:56 -0700

> This would be separate from the 'features' patches that are floating
> around.

netdev->features is how you should implement your patch, please don't
create new facilities.

With netdev->features they can be validated against netdev->hw_features
which, in this case, r8169 would have this feature bit clear.

That's how all of this stuff is designed to work, the driver says what
the hardware can do and thus ethtool generically can validate attempts
to turn on features.

No new facilities are necessary at all.
