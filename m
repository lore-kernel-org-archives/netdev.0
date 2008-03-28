From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Thu, 27 Mar 2008 17:01:38 -0800
Message-ID: <1206666100.5368.6.camel@dell>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org>
 <20080327.144925.196529669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: harald@iki.fi, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1067 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112AbYC1AGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:06:42 -0400
In-Reply-To: <20080327.144925.196529669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-27 at 14:49 -0700, David Miller wrote:
> From: Harald Hannelius <harald@iki.fi>
> Date: Thu, 27 Mar 2008 15:53:56 +0200 (EET)
> 
> > I experience a lot of hardware interrupts with a BCM5751 PCI-express NIC 
> > (tg3). modprobe tg3, ifconfig ethX up and friends makes the system 
> > unresponsive. Just having the interface up makes the system sluggish.
> > 

I just tested a similar NIC using the same kernel and driver, but I did
not notice anything unusual.  netperf gave me 941Mbps.

> > Onboard forcedeth works fine (with the same cable).
> > 
> > iperf gives me just 2Mbps on a 1Gbps ethernet. Load average near 1.0. top 
> > reports 40-50%hi (hardware interrupts) when generating traffic over that 
> > interface.

Can you look at /proc/interrupts to see roughly how many are reported
per second when link is down, link is up with no traffic, and with
traffic?

Finally, you can also try ethtool -t eth0 to see if it passes a simple
self test.

