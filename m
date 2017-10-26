From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vsock: always call vsock_init_tables()
Date: Thu, 26 Oct 2017 17:46:24 +0900 (KST)
Message-ID: <20171026.174624.903685303942814356.davem@davemloft.net>
References: <20171024223037.4856-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com, jhansen@vmware.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdJZIqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:46:30 -0400
In-Reply-To: <20171024223037.4856-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 24 Oct 2017 15:30:37 -0700

> Although CONFIG_VSOCKETS_DIAG depends on CONFIG_VSOCKETS,
> vsock_init_tables() is not always called, it is called only
> if other modules call its caller. Therefore if we only
> enable CONFIG_VSOCKETS_DIAG, it would crash kernel on uninitialized
> vsock_bind_table.
> 
> This patch fixes it by moving vsock_init_tables() to its own
> module_init().
> 
> Fixes: 413a4317aca7 ("VSOCK: add sock_diag interface")
> Reported-by: syzkaller bot
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
