From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] cxgb4 update
Date: Wed, 16 Jun 2010 17:48:52 -0700 (PDT)
Message-ID: <20100616.174852.15235899.davem@davemloft.net>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
	<20100616.174527.35032483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754545Ab0FQAsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 20:48:40 -0400
In-Reply-To: <20100616.174527.35032483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 16 Jun 2010 17:45:27 -0700 (PDT)

> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Wed, 16 Jun 2010 15:01:07 -0700
> 
>> 
>> Here's a series of 9 patches for the cxgb4 driver.  The changes include
>> support for larger flash memories, addition of EEH, an update to latest
>> fw api, and assorted few liners.  All patches are for net-next.
> 
> All applied, thanks.

Actually, I'm reverting, this breaks the infiniband driver build:

drivers/infiniband/hw/cxgb4/qp.c: In function 'post_terminate':
drivers/infiniband/hw/cxgb4/qp.c:882:18: error: 'FW_RI_INIT_WR' undeclared (first use in this function)
drivers/infiniband/hw/cxgb4/qp.c:882:18: note: each undeclared identifier is reported only once for each function it appears in
drivers/infiniband/hw/cxgb4/qp.c: In function 'rdma_fini':
drivers/infiniband/hw/cxgb4/qp.c:971:18: error: 'FW_RI_INIT_WR' undeclared (first use in this function)
drivers/infiniband/hw/cxgb4/qp.c: In function 'rdma_init':
drivers/infiniband/hw/cxgb4/qp.c:1045:18: error: 'FW_RI_INIT_WR' undeclared (first use in this function)
make[3]: *** [drivers/infiniband/hw/cxgb4/qp.o] Error 1
