From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipip: fix one sparse error
Date: Sun, 17 May 2015 14:11:48 -0400 (EDT)
Message-ID: <20150517.141148.1479901477654482092.davem@davemloft.net>
References: <1431705525.27831.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbbEQSLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 14:11:50 -0400
In-Reply-To: <1431705525.27831.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 May 2015 08:58:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/ipip.o
>   CHECK   net/ipv4/ipip.c
> net/ipv4/ipip.c:254:27: warning: incorrect type in assignment (different base types)
> net/ipv4/ipip.c:254:27:    expected restricted __be32 [addressable] [usertype] o_key
> net/ipv4/ipip.c:254:27:    got restricted __be16 [addressable] [usertype] i_flags
> 
> Fixes: 3b7b514f44bf ("ipip: fix a regression in ioctl")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
