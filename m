From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix ovs support
Date: Mon, 13 Mar 2017 16:04:20 -0700 (PDT)
Message-ID: <20170313.160420.747178801497689156.davem@davemloft.net>
References: <1489418643-32092-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754366AbdCMXEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:04:21 -0400
In-Reply-To: <1489418643-32092-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 13 Mar 2017 16:24:03 +0100

> The required changes in the function vxlan_dev_create() were missing
> in commit 8bcdc4f3a20b.
> The vxlan device is not registered anymore after this patch and the error
> path causes an stack dump:
>  WARNING: CPU: 3 PID: 1498 at net/core/dev.c:6713 rollback_registered_many+0x9d/0x3f0
> 
> Fixes: 8bcdc4f3a20b ("vxlan: add changelink support")
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thank you.
