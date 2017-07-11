From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Fix printk option passed when printing ipv6
 addresses
Date: Tue, 11 Jul 2017 13:36:21 -0700 (PDT)
Message-ID: <20170711.133621.992406600321132485.davem@davemloft.net>
References: <1499594416-20850-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
        Yuval.Mintz@cavium.com
To: Michal.Kalderon@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753829AbdGKUgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:36:22 -0400
In-Reply-To: <1499594416-20850-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>
Date: Sun, 9 Jul 2017 13:00:16 +0300

> The option "h" (host order ) exists for ipv4 only.
> Remove the h when printing ipv6 addresses.
> 
> Lead to the following smatch warning:
> 
> drivers/net/ethernet/qlogic/qed/qed_iwarp.c:585 qed_iwarp_print_tcp_ramrod()
> warn: '%pI6' can only be followed by c
> drivers/net/ethernet/qlogic/qed/qed_iwarp.c:1521 qed_iwarp_print_cm_info()
> warn: '%pI6' can only be followed by c
> 
> Fixes commit 456a584947d5 ("qed: iWARP CM add passive side connect")
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
