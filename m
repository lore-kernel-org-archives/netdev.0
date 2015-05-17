From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix sparse error in csum_replace4()
Date: Sun, 17 May 2015 14:11:42 -0400 (EDT)
Message-ID: <20150517.141142.1468655984264035723.davem@davemloft.net>
References: <1431705139.27831.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbbEQSLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 14:11:43 -0400
In-Reply-To: <1431705139.27831.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 May 2015 08:52:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/netfilter/nf_nat_l3proto_ipv4.o
>   CHECK   net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
> include/net/checksum.h:125:64: warning: incorrect type in argument 2 (different base types)
> include/net/checksum.h:125:64:    expected restricted __wsum [usertype] addend
> include/net/checksum.h:125:64:    got restricted __be32 [usertype] from
> include/net/checksum.h:125:71: warning: incorrect type in argument 2 (different base types)
> include/net/checksum.h:125:71:    expected restricted __wsum [usertype] addend
> include/net/checksum.h:125:71:    got restricted __be32 [usertype] to
> include/net/checksum.h:125:64: warning: incorrect type in argument 2 (different base types)
> include/net/checksum.h:125:64:    expected restricted __wsum [usertype] addend
> include/net/checksum.h:125:64:    got restricted __be32 [usertype] from
> include/net/checksum.h:125:71: warning: incorrect type in argument 2 (different base types)
> include/net/checksum.h:125:71:    expected restricted __wsum [usertype] addend
> include/net/checksum.h:125:71:    got restricted __be32 [usertype] to
> 
> Fixes: 4565af0d406b ("net: optimise csum_replace4()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
