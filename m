From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 11 Jan 2010 13:31:09 +1100
Message-ID: <20100111133109.a191ee64.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in include/linux/sysctl.h between commit 28f6aeea3f12d37bd258b2c0d5ba891bff4ec479 ("net: restore ip source validation") from Linus' tree and commit 65324144b50bc7022cc9b6ca8f4a536a957019e3 ("net: RFC3069, private VLAN proxy arp support") from the net tree.

They both use the same number in an enum...  I fixed it up (see below) and
can carry the fix (or some other) for a while.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/sysctl.h
index bd27fbc,24ff7e3..0000000
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@@ -482,7 -482,7 +482,8 @@@ enu
  	NET_IPV4_CONF_ARP_ACCEPT=21,
  	NET_IPV4_CONF_ARP_NOTIFY=22,
  	NET_IPV4_CONF_ACCEPT_LOCAL=23,
 -	NET_IPV4_CONF_PROXY_ARP_PVLAN=24,
 +	NET_IPV4_CONF_SRC_VMARK=24,
++	NET_IPV4_CONF_PROXY_ARP_PVLAN=25,
  	__NET_IPV4_CONF_MAX
  };
  
