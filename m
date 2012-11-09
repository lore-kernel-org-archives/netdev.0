From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: rlb mode of bond should not alter ARP replies
 originating via bridge
Date: Fri, 09 Nov 2012 16:25:28 -0500 (EST)
Message-ID: <20121109.162528.1251308488326610816.davem@davemloft.net>
References: <1352258580-8272-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, joe.jin@oracle.com
To: zheng.x.li@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352258580-8272-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <zheng.x.li@oracle.com>
Date: Wed,  7 Nov 2012 11:23:00 +0800

> ARP traffic passing through a bridge and out via the bond (when the bond is a 
> port of the bridge) should not have its source MAC address adjusted by the 
> receive load balance code in rlb_arp_xmit.
> 
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>

Please format these change properly, this is not indented
correctly at all:

> +				if (ether_addr_equal_64bits(arp->mac_src,
> +						tmp_slave->dev->dev_addr)) {
> +					memcpy(arp->mac_src,
> +						tx_slave->dev->dev_addr,
> +						ETH_ALEN);
> +					break;

Arguments to functions should line up, always, with the first column
after the openning parenthesis of the function call.

If that makes the far right column of the line go too far past
80 columns, too bad.  Make and use a helper function to perform
this test in that case.

Thanks.
