From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1605/1613] net/tipc/link.c:166:6: sparse: symbol
 'link_is_bc_sndlink' was not declared. Should it be static?
Date: Sat, 24 Oct 2015 22:56:00 +0800
Message-ID: <201510242238.2cwVlzRz%fengguang.wu@intel.com>
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
commit: 5266698661401afc5e4a1a521cf9ba10724d10dd [1605/1613] tipc: let broadcast packet reception use new link receive function
reproduce:
        # apt-get install sparse
        git checkout 5266698661401afc5e4a1a521cf9ba10724d10dd
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/tipc/link.c:166:6: sparse: symbol 'link_is_bc_sndlink' was not declared. Should it be static?
>> net/tipc/link.c:171:6: sparse: symbol 'link_is_bc_rcvlink' was not declared. Should it be static?
   net/tipc/link.c:635:6: sparse: symbol 'link_prepare_wakeup' was not declared. Should it be static?
   net/tipc/link.c:891:6: sparse: symbol 'tipc_link_advance_backlog' was not declared. Should it be static?
   net/tipc/link.c:967:5: sparse: symbol 'tipc_link_retrans' was not declared. Should it be static?
>> net/tipc/link.c:1561:6: sparse: symbol 'tipc_link_build_bc_init_msg' was not declared. Should it be static?
   include/linux/rcupdate.h:305:9: sparse: context imbalance in 'tipc_link_find_owner' - wrong count at exit
   net/tipc/link.c:1821:5: sparse: context imbalance in 'tipc_nl_link_set' - different lock contexts for basic block
   net/tipc/link.c:2058:5: sparse: context imbalance in 'tipc_nl_link_dump' - different lock contexts for basic block
   net/tipc/link.c:2129:5: sparse: context imbalance in 'tipc_nl_link_get' - different lock contexts for basic block
   net/tipc/link.c:2181:5: sparse: context imbalance in 'tipc_nl_link_reset_stats' - different lock contexts for basic block
--
   net/tipc/node.c:144:18: sparse: symbol 'tipc_node_create' was not declared. Should it be static?
   net/tipc/node.c:831:6: sparse: symbol 'tipc_node_filter_pkt' was not declared. Should it be static?
>> net/tipc/node.c:1090:6: sparse: symbol 'tipc_node_bc_rcv' was not declared. Should it be static?
   net/tipc/node.c:237:5: sparse: context imbalance in 'tipc_node_add_conn' - different lock contexts for basic block
   net/tipc/node.c:268:6: sparse: context imbalance in 'tipc_node_remove_conn' - different lock contexts for basic block
   net/tipc/node.c:303:9: sparse: context imbalance in 'tipc_node_timeout' - different lock contexts for basic block
   net/tipc/node.c:383:13: sparse: context imbalance in 'tipc_node_link_up' - wrong count at exit
   net/tipc/node.c:463:13: sparse: context imbalance in 'tipc_node_link_down' - wrong count at exit
   net/tipc/node.c:497:6: sparse: context imbalance in 'tipc_node_check_dest' - wrong count at exit
   net/tipc/node.c:917:9: sparse: context imbalance in 'tipc_node_get_linkname' - different lock contexts for basic block
   net/tipc/node.c:935:9: sparse: context imbalance in 'tipc_node_unlock' - unexpected unlock
   net/tipc/node.c:1027:5: sparse: context imbalance in 'tipc_node_xmit' - wrong count at exit
>> net/tipc/node.c:1090:6: sparse: context imbalance in 'tipc_node_bc_rcv' - wrong count at exit
   net/tipc/node.c:1277:6: sparse: context imbalance in 'tipc_rcv' - different lock contexts for basic block
   net/tipc/node.c:1348:5: sparse: context imbalance in 'tipc_nl_node_dump' - different lock contexts for basic block

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
