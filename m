From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix sparse endianness warnings on
 sock_common
Date: Sun, 02 Dec 2012 20:23:51 -0500 (EST)
Message-ID: <20121202.202351.2009817552547300312.davem@davemloft.net>
References: <1354469590.20109.585.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	ling.ma.program@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab2LCBXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 20:23:52 -0500
In-Reply-To: <1354469590.20109.585.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Dec 2012 09:33:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> # make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/inet_hashtables.o
> ...
> net/ipv4/inet_hashtables.c:242:7: warning: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:242:7: warning: restricted __addrpair degrades to integer
> ...
> 
> Move __portpair/__addrpair from include/net/inet_hashtables.h
> to include/net/sock.h where we need them in struct sock_common
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
