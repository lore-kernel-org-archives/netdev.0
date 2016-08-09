From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH RESEND net-next 08/15] smc: work request (WR) base for
 use by LLC and CDC
Date: Tue, 9 Aug 2016 20:29:44 +0800
Message-ID: <201608092045.OPf9gPOj%fengguang.wu@intel.com>
References: <1470737580-43012-9-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42118 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203AbcHIMad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 08:30:33 -0400
Content-Disposition: inline
In-Reply-To: <1470737580-43012-9-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ursula,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Ursula-Braun/net-smc-Shared-Memory-Communications-RDMA/20160809-182526


coccinelle warnings: (new ones prefixed by >>)

>> net/smc/smc_ib.c:45:14-21: ERROR: PTR_ERR applied after initialization to constant on line 44
   net/smc/smc_ib.c:98:14-21: ERROR: PTR_ERR applied after initialization to constant on line 97

vim +45 net/smc/smc_ib.c

    38	}
    39	
    40	int smc_ib_create_protection_domain(struct smc_link *lnk)
    41	{
    42		lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev);
    43		if (IS_ERR(lnk->roce_pd)) {
  > 44			lnk->roce_pd = NULL;
  > 45			return (int)PTR_ERR(lnk->roce_pd);
    46		}
    47		return 0;
    48	}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
