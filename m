From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gianfar: Change default HW Tx queue
 scheduling mode
Date: Fri, 21 Sep 2012 13:35:28 -0400 (EDT)
Message-ID: <20120921.133528.2219558580262606729.davem@davemloft.net>
References: <1348156674-31551-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932268Ab2IURfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:35:30 -0400
In-Reply-To: <1348156674-31551-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 20 Sep 2012 18:57:54 +0300

> The TXSCHED setting may be changed at runtime, via sysfs, for devices
> using multiple H/W Tx queues. For single queue devices this config
> option is disabled, as the TXSCHED setting is superfluous in those cases.

Please, no special driver specific sysfs knobs.

Extend ethtool as necessary for your needs, so that any driver can
provide this kind of configurability in a consistent way for users..
