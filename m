From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: handle interrupt raised when FW crashes
Date: Thu, 08 Jun 2017 15:38:41 -0400 (EDT)
Message-ID: <20170608.153841.1633074884358599473.davem@davemloft.net>
References: <1496909601-29370-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com,
        rahul.lakkireddy@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdFHTin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 15:38:43 -0400
In-Reply-To: <1496909601-29370-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu,  8 Jun 2017 13:43:21 +0530

> From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> 
> Handle TIMER0INT when FW crashes. Check for PCIE_FW[FW_EVAL]
> and if it says "Device FW Crashed", then treat it as fatal.
> Else, non-fatal.
> 
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
 ...
> @@ -4075,10 +4076,26 @@ static void cim_intr_handler(struct adapter *adapter)
>  	};
>  
>  	int fat;
> +	u32 val, fw_err;

Please respect the reverse christmas tree variable ordering.

Thank you.
