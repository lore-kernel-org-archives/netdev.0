From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Add MIB counters for checksum errors
Date: Mon, 29 Apr 2013 15:17:37 -0400 (EDT)
Message-ID: <20130429.151737.657155400434432034.davem@davemloft.net>
References: <1367260796.8964.331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760537Ab3D2TRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:17:39 -0400
In-Reply-To: <1367260796.8964.331.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Apr 2013 11:39:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Add MIB counters for checksum errors in IP layer,
> and TCP/UDP/ICMP layers, to help diagnose problems.
> 
> $ nstat -a | grep  Csum
> IcmpInCsumErrors                72                 0.0
> TcpInCsumErrors                 382                0.0
> UdpInCsumErrors                 463221             0.0
> Icmp6InCsumErrors               75                 0.0
> Udp6InCsumErrors                173442             0.0
> IpExtInCsumErrors               10884              0.0
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
