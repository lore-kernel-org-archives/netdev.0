From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Tue, 12 Jan 2010 03:23:05 -0800 (PST)
Message-ID: <20100112.032305.223871701.davem@davemloft.net>
References: <1263295184.6037.26.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751346Ab0ALLW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 06:22:57 -0500
In-Reply-To: <1263295184.6037.26.camel@braunu-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 12 Jan 2010 12:19:44 +0100

> An HS NTA device in Linux on System z is a specialized HiperSockets
> device managed by the qeth driver and initialized specifically for
> sniffing. The trigger for an HS device to act as a Network Traffic
> Analyzer is the sysfs attribute "sniffer". If this attribute is set to
> 1, the NTA-specific initialization is started when the HS device is
> brought online. Traffic sniffing starts, once the device is switched
> into promiscuous mode, for instance by invoking the tcpdump-tool.

Sounds like something which might be useful for other
virtualized environments.

At worst, they would be able to provide some similar
facility, and therefore the configuration mechanism to
turn this on should be unified.

Perhaps an ethtool boolean flag setting or similar,
rather than a baroque and driver specific sysfs knob.
