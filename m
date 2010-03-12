From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Fri, 12 Mar 2010 14:33:30 -0800 (PST)
Message-ID: <20100312.143330.79994779.davem@davemloft.net>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
	<20100312142302.30def236@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934667Ab0CLWdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 17:33:10 -0500
In-Reply-To: <20100312142302.30def236@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 12 Mar 2010 14:23:02 -0800

> On Fri, 12 Mar 2010 12:13:12 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
> 
>> if (unlikely(index >= dev->num_rx_queues)) {
>> +			if (net_ratelimit()) {
>> +				WARN(1, "Received packet on %s for queue %u, "
>> +				    "but number of RX queues is %u\n",
>> +				     dev->name, index, dev->num_rx_queues);
>> +			}
>> +			goto done;
> 
> 
> Use dev_WARN? or invent netdev_WARN?

Why invent?  egrep netdev_warn include/linux/netdevice.h
