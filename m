From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: suppress compiler warning
Date: Fri, 21 Sep 2012 13:49:26 -0400 (EDT)
Message-ID: <20120921.134926.991810355219428336.davem@davemloft.net>
References: <1348223124.1581.15.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519Ab2IURt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:49:29 -0400
In-Reply-To: <1348223124.1581.15.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Fri, 21 Sep 2012 12:25:24 +0200

> Building the hfcpci driver triggers this GCC warning:
>     drivers/isdn/hardware/mISDN/hfcpci.c:2298:2: warning: ignoring return value of 'driver_for_each_device', declared with attribute warn_unused_result [-Wunused-result]
> 
> That return value is apparently ignored because _hfcpci_softirq() will
> always return 0. Suppress this warning in the way a few other drivers do
> that too.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

This is pretty pointless and I'm therefore not applying it.
