From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next 1/8] net: stmicro: multiple queues dt configuration
 (fwd)
Date: Thu, 9 Mar 2017 21:56:09 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1703092154301.2306@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>,
        kbuild-all@01.org, davem@davemloft.net
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:35545 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750880AbdCIU4M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 15:56:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just pointing out that lines 200 and 202 are identical.

julia

---------- Forwarded message ----------
Date: Fri, 10 Mar 2017 04:50:01 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next 1/8] net: stmicro: multiple queues dt configuration

In-Reply-To: <eee93719e5830cfea8e4dcfdac9221a3b6124eb8.1488969672.git.jpinto@synopsys.com>

Hi Joao,

[auto build test WARNING on next-20170308]
[also build test WARNING on v4.11-rc1]
[cannot apply to v4.9-rc8 v4.9-rc7 v4.9-rc6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Joao-Pinto/prepare-mac-operations-for-multiple-queues/20170310-013207
:::::: branch date: 3 hours ago
:::::: commit date: 3 hours ago

>> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:199:6-8: WARNING: possible condition with no effect (if == else)

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout faca7330d9494884feb52b62a037d01266b4d382
vim +199 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c

faca7330 Joao Pinto 2017-03-08  183  		/* TODO: Dynamic mapping to be included in the future */
faca7330 Joao Pinto 2017-03-08  184
faca7330 Joao Pinto 2017-03-08  185  		queue++;
faca7330 Joao Pinto 2017-03-08  186  	}
faca7330 Joao Pinto 2017-03-08  187
faca7330 Joao Pinto 2017-03-08  188  	/* Processing TX queues common config */
faca7330 Joao Pinto 2017-03-08  189  	if (of_property_read_u8(tx_node, "snps,tx-queues-to-use",
faca7330 Joao Pinto 2017-03-08  190  				&plat->tx_queues_to_use))
faca7330 Joao Pinto 2017-03-08  191  		plat->tx_queues_to_use = 1;
faca7330 Joao Pinto 2017-03-08  192
faca7330 Joao Pinto 2017-03-08  193  	if (of_property_read_bool(tx_node, "snps,tx-sched-wrr"))
faca7330 Joao Pinto 2017-03-08  194  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WRR;
faca7330 Joao Pinto 2017-03-08  195  	else if (of_property_read_bool(tx_node, "snps,tx-sched-wfq"))
faca7330 Joao Pinto 2017-03-08  196  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WFQ;
faca7330 Joao Pinto 2017-03-08  197  	else if (of_property_read_bool(tx_node, "snps,tx-sched-dwrr"))
faca7330 Joao Pinto 2017-03-08  198  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_DWRR;
faca7330 Joao Pinto 2017-03-08 @199  	else if (of_property_read_bool(tx_node, "snps,tx-sched-sp"))
faca7330 Joao Pinto 2017-03-08  200  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
faca7330 Joao Pinto 2017-03-08  201  	else
faca7330 Joao Pinto 2017-03-08  202  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
faca7330 Joao Pinto 2017-03-08  203
faca7330 Joao Pinto 2017-03-08  204  	queue = 0;
faca7330 Joao Pinto 2017-03-08  205
faca7330 Joao Pinto 2017-03-08  206  	/* Processing individual TX queue config */
faca7330 Joao Pinto 2017-03-08  207  	for_each_child_of_node(tx_node, queue_node) {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
