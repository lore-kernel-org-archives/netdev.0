From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: make tcp_notsent_lowat sysctl knob behave as
 true unsigned int
Date: Mon, 09 Jan 2017 16:38:41 -0500 (EST)
Message-ID: <20170109.163841.473518915535228188.davem@davemloft.net>
References: <20161230.152325.1460360247883491150.davem@davemloft.net>
        <20170109074549.12220-1-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, khorenko@virtuozzo.com
To: ptikhomirov@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933772AbdAIVio (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:38:44 -0500
In-Reply-To: <20170109074549.12220-1-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Date: Mon,  9 Jan 2017 10:45:49 +0300

>> cat /proc/sys/net/ipv4/tcp_notsent_lowat
> -1
>> echo 4294967295 > /proc/sys/net/ipv4/tcp_notsent_lowat
> -bash: echo: write error: Invalid argument
>> echo -2147483648 > /proc/sys/net/ipv4/tcp_notsent_lowat
>> cat /proc/sys/net/ipv4/tcp_notsent_lowat
> -2147483648
> 
> but in documentation we have "tcp_notsent_lowat - UNSIGNED INTEGER"
> 
> v2: simplify to just proc_douintvec
> Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>

Applied.
