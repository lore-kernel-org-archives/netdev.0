From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] wan: pc300too: abort path on failure
Date: Mon, 24 Apr 2017 15:51:50 -0400 (EDT)
Message-ID: <20170424.155150.2291676361142019268.davem@davemloft.net>
References: <1492940315-1462-1-git-send-email-bianpan201602@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bianpan2016@163.com
To: bianpan201602@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977049AbdDXTv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:51:57 -0400
In-Reply-To: <1492940315-1462-1-git-send-email-bianpan201602@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan201602@163.com>
Date: Sun, 23 Apr 2017 17:38:35 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> In function pc300_pci_init_one(), on the ioremap error path, function
> pc300_pci_remove_one() is called to free the allocated memory. However,
> the path is not terminated, and the freed memory will be used later,
> resulting in use-after-free bugs. This path fixes the bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
