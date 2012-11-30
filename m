From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: rlb mode of bond should not alter ARP
 originating via bridge
Date: Fri, 30 Nov 2012 12:08:13 -0500 (EST)
Message-ID: <20121130.120813.1360888707923955813.davem@davemloft.net>
References: <1354096624-22380-1-git-send-email-zheng.x.li@oracle.com>
	<15005.1354213705@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zheng.x.li@oracle.com, netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, joe.jin@oracle.com
To: fubar@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15005.1354213705@death.nxdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Nov 2012 10:28:25 -0800

> Zheng Li <zheng.x.li@oracle.com> wrote:
> 
>>Do not modify or load balance ARP packets passing through balance-alb
>>mode (wherein the ARP did not originate locally, and arrived via a bridge).
>>
>>Modifying pass-through ARP replies causes an incorrect MAC address 
>>to be placed into the ARP packet, rendering peers unable to communicate 
>>with the actual destination from which the ARP reply originated.
>>
>>Load balancing pass-through ARP requests causes an entry to be
>>created for the peer in the rlb table, and bond_alb_monitor will
>>occasionally issue ARP updates to all peers in the table instrucing them
>>as to which MAC address they should communicate with; this occurs when
>>some event sets rx_ntt.  In the bridged case, however, the MAC address
>>used for the update would be the MAC of the slave, not the actual source
>>MAC of the originating destination.  This would render peers unable to
>>communicate with the destinations beyond the bridge.
>>
>>Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>>Cc: Jay Vosburgh <fubar@us.ibm.com>
>>Cc: Andy Gospodarek <andy@greyhouse.net>
>>Cc: "David S. Miller" <davem@davemloft.net>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
