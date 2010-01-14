From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Wed, 13 Jan 2010 20:35:15 -0800 (PST)
Message-ID: <20100113.203515.28836592.davem@davemloft.net>
References: <1263299131.6037.44.camel@braunu-laptop>
	<20100112.045944.197636957.davem@davemloft.net>
	<1263302964.6037.54.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752262Ab0ANEfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:35:08 -0500
In-Reply-To: <1263302964.6037.54.camel@braunu-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 12 Jan 2010 14:29:24 +0100

> I should have been more precise: In the s390-world there are 2 steps for
> network device setup - a ccwgroup-step, which establishes the "struct
> device", and an online-step, which establishes the "struct net_device".
> After the ccwgroup-step we have an instantiated device and can make use
> of sysfs. After the online-step, we have an instantiated net_device
> incl. network interface name and can make use of ethtool. HiperSockets
> sniffer configuration is required before the online-step.

Fair enough.

Ok, all 3 qeth patches applied to net-next-2.6, thanks.
