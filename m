From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next 1/8] net: stmicro: multiple queues dt
 configuration (fwd)
Date: Fri, 10 Mar 2017 10:35:03 +0000
Message-ID: <7d3888f1-79c6-42f5-2e21-3c6f219b5c55@synopsys.com>
References: <alpine.DEB.2.20.1703092154301.2306@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <kbuild-all@01.org>,
        <davem@davemloft.net>
To: Julia Lawall <julia.lawall@lip6.fr>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:49513 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934944AbdCJKfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 05:35:10 -0500
In-Reply-To: <alpine.DEB.2.20.1703092154301.2306@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Julia,

Às 8:56 PM de 3/9/2017, Julia Lawall escreveu:
> This is just pointing out that lines 200 and 202 are identical.

Yes you are correct. I put like this because you can have an algorithm
configured, but for some reason you may forget to declare it and so I am
assuming Strict Priority as the default, if no algorithm is mentioned.

Thanks.

> 
> julia
> 
> ---------- Forwarded message ----------
> Date: Fri, 10 Mar 2017 04:50:01 +0800
> From: kbuild test robot <fengguang.wu@intel.com>
> To: kbuild@01.org
> Cc: Julia Lawall <julia.lawall@lip6.fr>
> Subject: Re: [PATCH net-next 1/8] net: stmicro: multiple queues dt configuration
> 
> In-Reply-To: <eee93719e5830cfea8e4dcfdac9221a3b6124eb8.1488969672.git.jpinto@synopsys.com>
> 
> Hi Joao,
> 
> [auto build test WARNING on next-20170308]
> [also build test WARNING on v4.11-rc1]
> [cannot apply to v4.9-rc8 v4.9-rc7 v4.9-rc6]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux_commits_Joao-2DPinto_prepare-2Dmac-2Doperations-2Dfor-2Dmultiple-2Dqueues_20170310-2D013207&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=a9WPde3r_rvMfiI6cNc9fiisfaNuQ0Y6Db3AlCshStc&s=UN6vsTbyCs5xra4Pmdmeh5SJtlHnMYuqY2G7dEzfH8A&e= 
> :::::: branch date: 3 hours ago
> :::::: commit date: 3 hours ago
> 
>>> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:199:6-8: WARNING: possible condition with no effect (if == else)
> 
> git remote add linux-review https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=a9WPde3r_rvMfiI6cNc9fiisfaNuQ0Y6Db3AlCshStc&s=77GWKJ7l6ZN9uZytFPLhSHX_eDkoS_xGee1Bqiz4bng&e= 
> git remote update linux-review
> git checkout faca7330d9494884feb52b62a037d01266b4d382
> vim +199 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> 
> faca7330 Joao Pinto 2017-03-08  183  		/* TODO: Dynamic mapping to be included in the future */
> faca7330 Joao Pinto 2017-03-08  184
> faca7330 Joao Pinto 2017-03-08  185  		queue++;
> faca7330 Joao Pinto 2017-03-08  186  	}
> faca7330 Joao Pinto 2017-03-08  187
> faca7330 Joao Pinto 2017-03-08  188  	/* Processing TX queues common config */
> faca7330 Joao Pinto 2017-03-08  189  	if (of_property_read_u8(tx_node, "snps,tx-queues-to-use",
> faca7330 Joao Pinto 2017-03-08  190  				&plat->tx_queues_to_use))
> faca7330 Joao Pinto 2017-03-08  191  		plat->tx_queues_to_use = 1;
> faca7330 Joao Pinto 2017-03-08  192
> faca7330 Joao Pinto 2017-03-08  193  	if (of_property_read_bool(tx_node, "snps,tx-sched-wrr"))
> faca7330 Joao Pinto 2017-03-08  194  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WRR;
> faca7330 Joao Pinto 2017-03-08  195  	else if (of_property_read_bool(tx_node, "snps,tx-sched-wfq"))
> faca7330 Joao Pinto 2017-03-08  196  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WFQ;
> faca7330 Joao Pinto 2017-03-08  197  	else if (of_property_read_bool(tx_node, "snps,tx-sched-dwrr"))
> faca7330 Joao Pinto 2017-03-08  198  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_DWRR;
> faca7330 Joao Pinto 2017-03-08 @199  	else if (of_property_read_bool(tx_node, "snps,tx-sched-sp"))
> faca7330 Joao Pinto 2017-03-08  200  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
> faca7330 Joao Pinto 2017-03-08  201  	else
> faca7330 Joao Pinto 2017-03-08  202  		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
> faca7330 Joao Pinto 2017-03-08  203
> faca7330 Joao Pinto 2017-03-08  204  	queue = 0;
> faca7330 Joao Pinto 2017-03-08  205
> faca7330 Joao Pinto 2017-03-08  206  	/* Processing individual TX queue config */
> faca7330 Joao Pinto 2017-03-08  207  	for_each_child_of_node(tx_node, queue_node) {
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.01.org_pipermail_kbuild-2Dall&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=a9WPde3r_rvMfiI6cNc9fiisfaNuQ0Y6Db3AlCshStc&s=FIMUAwoZnmD9TLcn9NWRiOonj4uGrJQ1d_-POnyob5k&e=                    Intel Corporation
> 
