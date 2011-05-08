From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide
 error
Date: Sun, 08 May 2011 15:52:15 -0700 (PDT)
Message-ID: <20110508.155215.242144177.davem@davemloft.net>
References: <20110504123738.7bb4d1ee@nehalam>
	<20110504.124053.260068550.davem@davemloft.net>
	<20110504130456.425dee68@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sangtae.ha@gmail.com, injongrhee@gmail.com,
	Valdis.Kletnieks@vt.edu, rdunlap@xenotime.net, lkml@techboom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504130456.425dee68@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 May 2011 13:04:56 -0700

> TCP Cubic keeps a metric that estimates the amount of delayed
> acknowledgements to use in adjusting the window. If an abnormally
> large number of packets are acknowledged at once, then the update
> could wrap and reach zero. This kind of ACK could only
> happen when there was a large window and huge number of
> ACK's were lost.
> 
> This patch limits the value of delayed ack ratio. The choice of 32
> is just a conservative value since normally it should be range of 
> 1 to 4 packets.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
