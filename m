From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: check sk sk_type and protocol early in
 ip_mroute_set/getsockopt
Date: Sun, 26 Feb 2017 21:26:21 -0500 (EST)
Message-ID: <20170226.212621.1471488214595328803.davem@davemloft.net>
References: <3d5396c3b5950c5a7476cf8a69198f916b4f01a4.1487924946.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdB0Cco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:32:44 -0500
In-Reply-To: <3d5396c3b5950c5a7476cf8a69198f916b4f01a4.1487924946.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 24 Feb 2017 16:29:06 +0800

> Commit 5e1859fbcc3c ("ipv4: ipmr: various fixes and cleanups") fixed
> the issue for ipv4 ipmr:
> 
>   ip_mroute_setsockopt() & ip_mroute_getsockopt() should not
>   access/set raw_sk(sk)->ipmr_table before making sure the socket
>   is a raw socket, and protocol is IGMP
> 
> The same fix should be done for ipv6 ipmr as well.
> 
> This patch can fix the panic caused by overwriting the same offset
> as ipmr_table as in raw_sk(sk) when accessing other type's socket
> by ip_mroute_setsockopt().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
