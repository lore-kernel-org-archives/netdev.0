From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: fix missing unlock on error in
 __ibmvnic_reset()
Date: Thu, 18 May 2017 15:18:47 -0400 (EDT)
Message-ID: <20170518.151847.1221004357174431330.davem@davemloft.net>
References: <20170518152452.8606-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com, weiyongjun1@huawei.com,
        linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932262AbdERTS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 15:18:56 -0400
In-Reply-To: <20170518152452.8606-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 18 May 2017 15:24:52 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Add the missing unlock before return from function __ibmvnic_reset()
> in the error handling case.
> 
> Fixes: ed651a10875f ("ibmvnic: Updated reset handling")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
