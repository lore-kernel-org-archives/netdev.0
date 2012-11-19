From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: rlb mode of bond should not alter ARP
 originating via bridge
Date: Mon, 19 Nov 2012 18:49:45 -0500 (EST)
Message-ID: <20121119.184945.1954927437456820612.davem@davemloft.net>
References: <1352972861-17577-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, joe.jin@oracle.com
To: zheng.x.li@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352972861-17577-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <zheng.x.li@oracle.com>
Date: Thu, 15 Nov 2012 17:47:41 +0800

> ARP traffic passing through a bridge and out via the bond (when the bond is a 
> port of the bridge) should not have its source MAC address adjusted by the 
> receive load balance code in rlb_arp_xmit.
> 
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>

Can I please get a review from some bonding experts on this one?

Thanks!
