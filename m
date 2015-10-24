From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1610/1613] net/tipc/link.c:176:5: sparse: symbol
 'tipc_link_is_active' was not declared. Should it be static?
Date: Sat, 24 Oct 2015 23:11:00 +0800
Message-ID: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Jon Paul Maloy <jon.maloy@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   687f079addba1ac7f97ce97080c2291bbe8c8dce
commit: c72fa872a23f03b2b9c17e88f3b0a8070924e5f1 [1610/1613] tipc: eliminate link's reference to owner node
reproduce:
        # apt-get install sparse
        git checkout c72fa872a23f03b2b9c17e88f3b0a8070924e5f1
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   net/tipc/link.c:166:6: sparse: symbol 'link_is_bc_sndlink' was not declared. Should it be static?
   net/tipc/link.c:171:6: sparse: symbol 'link_is_bc_rcvlink' was not declared. Should it be static?
>> net/tipc/link.c:176:5: sparse: symbol 'tipc_link_is_active' was not declared. Should it be static?
   net/tipc/link.c:648:6: sparse: symbol 'link_prepare_wakeup' was not declared. Should it be static?
   net/tipc/link.c:904:6: sparse: symbol 'tipc_link_advance_backlog' was not declared. Should it be static?
   net/tipc/link.c:980:5: sparse: symbol 'tipc_link_retrans' was not declared. Should it be static?
   net/tipc/link.c:1573:6: sparse: symbol 'tipc_link_build_bc_init_msg' was not declared. Should it be static?
   include/linux/rcupdate.h:305:9: sparse: context imbalance in 'tipc_link_find_owner' - wrong count at exit
   net/tipc/link.c:1833:5: sparse: context imbalance in 'tipc_nl_link_set' - different lock contexts for basic block
   net/tipc/link.c:2070:5: sparse: context imbalance in 'tipc_nl_link_dump' - different lock contexts for basic block
   net/tipc/link.c:2141:5: sparse: context imbalance in 'tipc_nl_link_get' - different lock contexts for basic block
   net/tipc/link.c:2193:5: sparse: context imbalance in 'tipc_nl_link_reset_stats' - different lock contexts for basic block

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
