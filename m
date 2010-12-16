From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: add the debugfs interface to see RLB hash
 table
Date: Thu, 16 Dec 2010 12:35:23 -0800 (PST)
Message-ID: <20101216.123523.246538617.davem@davemloft.net>
References: <4CF89A00.8030902@jp.fujitsu.com>
	<4CF89AC2.6030606@jp.fujitsu.com>
	<4D05A96B.7020902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755201Ab0LPUez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 15:34:55 -0500
In-Reply-To: <4D05A96B.7020902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Mon, 13 Dec 2010 14:04:43 +0900

> 
> This patch provices the debugfs interface to see RLB hash table
> like the following:
> 
> # cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
> SourceIP        DestinationIP   Destination MAC   DEV
> 10.124.196.205  10.124.196.205  ff:ff:ff:ff:ff:ff eth4
> 10.124.196.205  10.124.196.81   00:19:99:XX:XX:XX eth3
> 10.124.196.205  10.124.196.1    00:21:d8:XX:XX:XX eth0
> 
> This is helpful to check if the receive load balancing works as expected.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
