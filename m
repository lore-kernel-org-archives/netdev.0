From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] iptunnel: make rx/tx bytes counters consistent
Date: Sun, 20 Sep 2015 22:35:13 -0700 (PDT)
Message-ID: <20150920.223513.1872161134519661761.davem@davemloft.net>
References: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbbIUFfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:35:14 -0400
In-Reply-To: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 18 Sep 2015 11:47:40 +0200

> This was already done a long time ago in
> commit 64194c31a0b6 ("inet: Make tunnel RX/TX byte counters more consistent")
> but tx path was broken (at least since 3.10).
> 
> Before the patch the gre header was included on tx.
> 
> After the patch:
> $ ping -c1 192.168.0.121 ; ip -s l ls dev gre1
> PING 192.168.0.121 (192.168.0.121) 56(84) bytes of data.
> 64 bytes from 192.168.0.121: icmp_req=1 ttl=64 time=2.95 ms
> 
> --- 192.168.0.121 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 2.955/2.955/2.955/0.000 ms
> 7: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN mode DEFAULT group default
>     link/gre 10.16.0.249 peer 10.16.0.121
>     RX: bytes  packets  errors  dropped overrun mcast
>     84         1        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     84         1        0       0       0       0
> 
> Reported-by: Julien Meunier <julien.meunier@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
