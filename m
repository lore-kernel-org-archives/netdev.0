From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix sparse errors in ip6_make_flowlabel()
Date: Thu, 05 Feb 2015 00:42:42 -0800 (PST)
Message-ID: <20150205.004242.1772120665803211740.davem@davemloft.net>
References: <1423091005.31870.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbbBEImn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:42:43 -0500
In-Reply-To: <1423091005.31870.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Feb 2015 15:03:25 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> include/net/ipv6.h:713:22: warning: incorrect type in assignment (different base types)
> include/net/ipv6.h:713:22:    expected restricted __be32 [usertype] hash
> include/net/ipv6.h:713:22:    got unsigned int
> include/net/ipv6.h:719:25: warning: restricted __be32 degrades to integer
> include/net/ipv6.h:719:22: warning: invalid assignment: ^=
> include/net/ipv6.h:719:22:    left side has type restricted __be32
> include/net/ipv6.h:719:22:    right side has type unsigned int
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
