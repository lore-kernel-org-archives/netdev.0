From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Sat, 01 Apr 2017 11:26:03 -0700 (PDT)
Message-ID: <20170401.112603.1991545644693496714.davem@davemloft.net>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
        <1491031554-19516-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com,
        robin.murphy@arm.com, jeffrey.t.kirsher@intel.com,
        alexander.duyck@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdDAS0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:26:10 -0400
In-Reply-To: <1491031554-19516-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 1 Apr 2017 15:25:51 +0800

> Till now only the Intel ixgbe could support enable
> Relaxed ordering in the drivers for special architecture,
> but the ARCH_WANT_RELAX_ORDER is looks like a general name
> for all arch, so rename to a specific name for intel
> card looks more appropriate.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

This is not a driver specific facility.

Any driver can test this symbol and act accordingly.

Just because IXGBE is the first and only user, doesn't mean
the facility is driver specific.

Thank you.
