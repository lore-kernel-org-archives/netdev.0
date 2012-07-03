From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 02 Jul 2012 18:04:58 -0700 (PDT)
Message-ID: <20120702.180458.2296165153479998120.davem@davemloft.net>
References: <20120702.013445.1273332212099485403.davem@davemloft.net>
	<1341252445.2590.12.camel@bwh-desktop.uk.solarflarecom.com>
	<20120702.171507.1288066003825644221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@kernel.org, yevgenyp@mellanox.com,
	oren@mellanox.com, netdev@vger.kernel.org, hadarh@mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831Ab2GCBFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:05:00 -0400
In-Reply-To: <20120702.171507.1288066003825644221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just in case you guys _really_ and _truly_ are so unable to think
outside the box that you can't come up with something reasonable, I'll
get you started with two ideas:

1) A special "chipset" dummy netdev that a special class of ethtool
   commands can run on to set these things.

2) A "chipset" genetlink family with suitable operations and
   attributes.

In both cases appropriate mechanisms are added to make for keys that
are used for chipset matching, and device drivers simply register
a notifier handler that is called on two occaisions:

1) When settings are changed.

2) Upon initial handler registry, to acquire the initial settings.
