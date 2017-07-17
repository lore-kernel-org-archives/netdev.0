From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bpf: check NULL for sk_to_full_sk() return value
Date: Mon, 17 Jul 2017 13:38:59 -0700 (PDT)
Message-ID: <20170717.133859.1744044057315886326.davem@davemloft.net>
References: <20170717184255.6121-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com, brakmo@fb.com,
        daniel@iogearbox.net
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdGQUjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 16:39:00 -0400
In-Reply-To: <20170717184255.6121-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 17 Jul 2017 11:42:55 -0700

> When req->rsk_listener is NULL, sk_to_full_sk() returns
> NULL too, so we have to check its return value against
> NULL here.
> 
> Fixes: 40304b2a1567 ("bpf: BPF support for sock_ops")
> Reported-by: David Ahern <dsahern@gmail.com>
> Tested-by: David Ahern <dsahern@gmail.com>
> Cc: Lawrence Brakmo <brakmo@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
