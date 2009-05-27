From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] igb: Record host memory receive
 overflow in net_stats
Date: Tue, 26 May 2009 20:36:24 -0700 (PDT)
Message-ID: <20090526.203624.32809185.davem@davemloft.net>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
	<20090526235048.28231.66889.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hawk@comx.dk
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753452AbZE0DgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:36:25 -0400
In-Reply-To: <20090526235048.28231.66889.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 16:50:48 -0700

> Based on previous patch from Jesper Dangaard Brouer.
> 
> The RNBC (Receive No Buffers Count) register for the 82576, indicate
> that frames were received when there were no available buffers in host
> memory to store those frames (receive descriptor head and tail
> pointers were equal).  The packet is still received by the NIC if
> there is space in the FIFO on the NIC.
> 
> As the RNBC value is not a packet drop, the driver stores this value
> in net_stats.rx_fifo_errors to indicate that there were no system
> buffers available for the incoming packet.  Actual dropped packets
> are counted in the MPC value.
> 
> Saving the stats in dev->net_stats makes it visible via
> /proc/net/dev as "fifo", and thus viewable to ifconfig
> as "overruns" and 'netstat -i' as "RX-OVR".
> 
> The Receive No Buffers Count (RNBC) can already be queried by
> ethtool -S as "rx_no_buffer_count".
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
