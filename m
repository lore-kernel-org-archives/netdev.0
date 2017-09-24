From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: qualcomm: rmnet: Fix rcu splat in
 rmnet_is_real_dev_registered
Date: Sat, 23 Sep 2017 20:00:32 -0700 (PDT)
Message-ID: <20170923.200032.1587798983817298384.davem@davemloft.net>
References: <1506038436-4865-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaolong.ye@intel.com, netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdIXDAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 23:00:36 -0400
In-Reply-To: <1506038436-4865-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 21 Sep 2017 18:00:36 -0600

> Xiaolong reported a suspicious rcu_dereference_check in the device
> unregister notifier callback. Since we do not dereference the
> rx_handler_data, it's ok to just check for the value of the pointer.
> Note that this section is already protected by rtnl_lock.
 ...
> Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Reported-by: kernel test robot <xiaolong.ye@intel.com>

Applied, thank you.
