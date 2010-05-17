From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 17 May 2010 12:09:22 +1000
Message-ID: <20100517120922.50d5e0fb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>,
	Chris Wright <chrisw@sous-sol.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
include/linux/if_link.h between commit
c02db8c6290bb992442fec1407643c94cc414375 ("rtnetlink: make SR-IOV VF
interface symmetric") from Linus' tree and commit
10708f37ae729baba9b67bd134c3720709d4ae62 ("net: core: add IFLA_STATS64
support") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix
for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/if_link.h
index d94963b,cfd420b..0000000
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@@ -79,7 -111,11 +111,8 @@@ enum 
  	IFLA_NET_NS_PID,
  	IFLA_IFALIAS,
  	IFLA_NUM_VF,		/* Number of VFs if device is SR-IOV PF */
 -	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 -	IFLA_VF_VLAN,
 -	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 -	IFLA_VFINFO,
 +	IFLA_VFINFO_LIST,
+ 	IFLA_STATS64,
  	__IFLA_MAX
  };
  
