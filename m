From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: Stop pretending to support
 netpoll
Date: Thu, 13 Mar 2014 15:26:16 -0400 (EDT)
Message-ID: <20140313.152616.852706173032905275.davem@davemloft.net>
References: <87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87ppls774g.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbaCMT0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:26:18 -0400
In-Reply-To: <87ppls774g.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Mar 2014 14:33:35 -0700

> bcm_enet_netpoll does not exist, and causing
> bcm63xx_net to fail to build when NET_POLL_CONTROLLER
> is defined.
> 
> Remove the bogus .ndo_poll_controller = bcm_enet_netpoll
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.

This driver doesn't get a lot of build testing, and that's due to the
platform BCM63XX kconfig option it depends upon.  Probably it should
be exposed more widely to perhaps a more broad dependency such as
CONFIG_OF.
