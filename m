From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH RESEND net-next 14/15] smc: socket closing and linkgroup
 cleanup
Date: Tue, 9 Aug 2016 20:55:59 +0800
Message-ID: <201608092041.K2P08ijT%fengguang.wu@intel.com>
References: <1470737580-43012-15-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12200 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240AbcHIM5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 08:57:00 -0400
Content-Disposition: inline
In-Reply-To: <1470737580-43012-15-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ursula,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Ursula-Braun/net-smc-Shared-Memory-Communications-RDMA/20160809-182526


coccinelle warnings: (new ones prefixed by >>)

>> net/smc/smc_wr.c:274:10-11: WARNING: return of 0/1 in function 'smc_wr_tx_has_pending' with return type bool
