From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Tue, 12 Jan 2010 04:59:44 -0800 (PST)
Message-ID: <20100112.045944.197636957.davem@davemloft.net>
References: <1263295184.6037.26.camel@braunu-laptop>
	<20100112.032305.223871701.davem@davemloft.net>
	<1263299131.6037.44.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55879
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751545Ab0ALM7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 07:59:37 -0500
In-Reply-To: <1263299131.6037.44.camel@braunu-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 12 Jan 2010 13:25:31 +0100

> Sounds like a good idea, but there exists a qeth-specific problem if
> sniffer configuration should be switched to ethtool: Ethtool requires
> the existence of the network interface for the network device. The
> network interface for s390 network devices is defined within an
> s390-specific initialization step called "online setting". The sniffing
> characteristic must be configured before the online setting of the
> device, since NTA-specific initialization steps are necessary. At that
> point of time we cannot make use of ethtool, because the network
> interface name is not known yet. That means switching to your proposed
> ethtool-based configuration mechanism for HS NTA would result in an
> additional major rework of qeth device setup.

If you have a place to stick sysfs nodes, you've obviously
instantiated the device already.
