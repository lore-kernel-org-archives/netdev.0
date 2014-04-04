From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: Inactive slaves should keep inactive
 flag's value
Date: Fri, 04 Apr 2014 10:04:38 -0400 (EDT)
Message-ID: <20140404.100438.264462269855449623.davem@davemloft.net>
References: <1396407708-4056-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, vfalico@redhat.com,
	linux-kernel@vger.kernel.org, joe.jin@oracle.com
To: zheng.x.li@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396407708-4056-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <zheng.x.li@oracle.com>
Date: Wed,  2 Apr 2014 11:01:48 +0800

> bond_open is not setting the inactive flag correctly for some modes (alb and
> tlb), resulting in error behavior if the bond has been administratively set
> down and then back up. This effect should not occur when slaves are added while
> the bond is up; it's something that only happens after a down/up bounce of the
> bond.
> 
> For example, in bond tlb or alb mode, domu send some ARP request which go out
> from dom0 bond's active slave, then the ARP broadcast request packets go back to
> inactive slave from switch, because the inactive slave's inactive flag is zero,
> kernel will receive the packets and pass them to bridge that cause dom0's bridge
> map domu's MAC address to port of bond, bridge should map domu's MAC to port of
> vif.
> 
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
> Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>

Applied.
