From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] TLS: Fix length check in
 do_tls_getsockopt_tx()
Date: Thu, 06 Jul 2017 10:58:48 +0100 (WEST)
Message-ID: <20170706.105848.1241930716639339836.davem@davemloft.net>
References: <5b6ff892-fd27-94c6-045a-70c6ab721fb3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
        davejwatson@fb.com, aviadye@mellanox.com, ilyal@mellanox.com
To: mrosenfelder.lkml@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbdGFJ6w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 05:58:52 -0400
In-Reply-To: <5b6ff892-fd27-94c6-045a-70c6ab721fb3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>
Date: Thu, 6 Jul 2017 00:56:36 -0400

> copy_to_user() copies the struct the pointer is pointing to, but the
> length check compares against sizeof(pointer) and not sizeof(struct).
> On 32-bit the size is probably the same, so it might have worked
> accidentally.
> 
> Signed-off-by: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>

Applied, thanks.
