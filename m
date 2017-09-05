From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net-next
 tree
Date: Tue, 5 Sep 2017 15:27:25 +1000
Message-ID: <20170905152725.4ae867b6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Varsha Rao <rvarsha016@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Krzysztof Kozlowski <krzk@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in:

  arch/sh/configs/se7751_defconfig

between commit:

  9efdb14f76f4 ("net: Remove CONFIG_NETFILTER_DEBUG and _ASSERT() macros.")

from the net-next tree and commit:

  a83883ff2285 ("sh: defconfig: cleanup from old Kconfig options")

from the akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/sh/configs/se7751_defconfig
index 56b5e4ce8d4a,153e1d3c8be5..000000000000
--- a/arch/sh/configs/se7751_defconfig
+++ b/arch/sh/configs/se7751_defconfig
@@@ -25,12 -24,10 +24,9 @@@ CONFIG_IP_PNP=
  CONFIG_IP_PNP_DHCP=y
  CONFIG_IP_PNP_BOOTP=y
  CONFIG_IP_PNP_RARP=y
- # CONFIG_INET_LRO is not set
  # CONFIG_IPV6 is not set
  CONFIG_NETFILTER=y
- CONFIG_IP_NF_QUEUE=y
 -CONFIG_NETFILTER_DEBUG=y
  CONFIG_MTD=y
- CONFIG_MTD_PARTITIONS=y
  CONFIG_MTD_BLOCK=y
  CONFIG_MTD_CFI=y
  CONFIG_MTD_CFI_AMDSTD=y
