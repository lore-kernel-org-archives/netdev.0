From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: move stub initialization after ipv6 setup
 completion
Date: Tue, 25 Apr 2017 11:43:29 -0400 (EDT)
Message-ID: <20170425.114329.1246693615604825040.davem@davemloft.net>
References: <fd7c85f650661466a782a71485f227f0b84454a7.1493035843.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032799AbdDYPnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:43:31 -0400
In-Reply-To: <fd7c85f650661466a782a71485f227f0b84454a7.1493035843.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 24 Apr 2017 14:18:28 +0200

> The ipv6 stub pointer is currently initialized before the ipv6
> routing subsystem: a 3rd party can access and use such stub
> before the routing data is ready.
> Moreover, such pointer is not cleared in case of initialization
> error, possibly leading to dangling pointers usage.
> 
> This change addresses the above moving the stub initialization
> at the end of ipv6 init code.
> 
> Fixes: 5f81bd2e5d80 ("ipv6: export a stub for IPv6 symbols used by vxlan")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
