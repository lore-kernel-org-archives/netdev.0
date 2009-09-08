From: robert@herjulf.net
Subject: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Tue, 8 Sep 2009 13:52:16 +0200
Message-ID: <19110.17776.721680.242313@gargle.gargle.HOWL>
References: <20090827235506.624381734@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:46830 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993AbZIHJvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 05:51:08 -0400
In-Reply-To: <20090827235506.624381734@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:
 > The biggest change is switching to monotonic clock (ktime) and
 > high resolution timers for the interpacket delay.

Opteron Barcelona 2.3 GHz with net-next 2.6.31-rc5bifrost-x86_64.

Sending different pkt-sizes at maxrate using one CPU-core (of eight) 
with ixgbe driver and Intel's 82598 chip.

      w. patch
64    4761904    3846153
128   4545454    3703703
256   4545454    3703703
512   2380952    2380952
1024  1204819    1204819
1500   826446     826446

We increase max sending rate from 3.8 Mpps to 4.8 Mpps for 64 byte pkts

Thanks a lot Stephen.

Cheers
                                        --ro
