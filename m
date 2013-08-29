From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: inherit slave devices needed_headroom
Date: Thu, 29 Aug 2013 15:17:30 -0400 (EDT)
Message-ID: <20130829.151730.1884423447346328497.davem@davemloft.net>
References: <1377601433-22353-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, eric.dumazet@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab3H2TRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:17:33 -0400
In-Reply-To: <1377601433-22353-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Tue, 27 Aug 2013 12:03:53 +0100

> Some slave devices may have set a dev->needed_headroom value which is
> different than the default one, most likely in order to prepend a
> hardware descriptor in front of the Ethernet frame to send. Whenever a
> new slave is added to a bridge, ensure that we update the
> needed_headroom value accordingly to account for the slave
> needed_headroom value.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Since this is a performance optimization I've applied this to net-next.

Thanks!
