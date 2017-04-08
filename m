From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] New getsockopt option to retrieve socket
 cookie
Date: Sat, 08 Apr 2017 08:07:24 -0700 (PDT)
Message-ID: <20170408.080724.442486952207900158.davem@davemloft.net>
References: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, willemb@google.com,
        fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdDHPHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:07:33 -0400
In-Reply-To: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Wed,  5 Apr 2017 19:00:54 -0700

> In the current kernel socket cookie implementation, there is no simple
> and direct way to retrieve the socket cookie based on file descriptor. A
> process mat need to get it from sock fd if it want to correlate with
> sock_diag output or use a bpf map with new socket cookie function.
> 
> If userspace wants to receive the socket cookie for a given socket fd,
> it must send a SOCK_DIAG_BY_FAMILY dump request and look for the 5-tuple.
> This is slow and can be ambiguous in the case of sockets that have the
> same 5-tuple (e.g., tproxy / transparent sockets, SO_REUSEPORT sockets,
> etc.).
> 
> As shown in the example program. The xt_eBPF program is using socket cookie
> to record the network traffics statistics and with the socket cookie
> retrieved by getsockopt. The program can directly access to a specific
> socket data without scanning the whole bpf map.

Series applied, thank you.
