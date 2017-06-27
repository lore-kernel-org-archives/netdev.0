From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix null ptr deref in getsockopt(...,
 TCP_ULP, ...)
Date: Tue, 27 Jun 2017 15:39:27 -0400 (EDT)
Message-ID: <20170627.153927.140891706842589227.davem@davemloft.net>
References: <20170626153647.GA15170@achao-mbp1.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, borisp@mellanox.com,
        alexander.levin@verizon.com, netdev@vger.kernel.org
To: davejwatson@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdF0Tj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:39:29 -0400
In-Reply-To: <20170626153647.GA15170@achao-mbp1.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Watson <davejwatson@fb.com>
Date: Mon, 26 Jun 2017 08:36:47 -0700

> If icsk_ulp_ops is unset, it dereferences a null ptr.
> Add a null ptr check.
> 
> BUG: KASAN: null-ptr-deref in copy_to_user include/linux/uaccess.h:168 [inline]
> BUG: KASAN: null-ptr-deref in do_tcp_getsockopt.isra.33+0x24f/0x1e30 net/ipv4/tcp.c:3057
> Read of size 4 at addr 0000000000000020 by task syz-executor1/15452
> 
> Signed-off-by: Dave Watson <davejwatson@fb.com>
> Reported-by: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>

Applied, thanks.
