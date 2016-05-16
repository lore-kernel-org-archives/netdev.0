From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: propagate __sock_cmsg_send() error
Date: Mon, 16 May 2016 13:46:57 -0400 (EDT)
Message-ID: <20160516.134657.356847091980945795.davem@davemloft.net>
References: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
	<1463145277.23934.186.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com, willemb@google.com, soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbcEPRrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:47:01 -0400
In-Reply-To: <1463145277.23934.186.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 May 2016 06:14:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __sock_cmsg_send() might return different error codes, not only -EINVAL.
> 
> Fixes: 24025c465f77 ("ipv4: process socket-level control messages in IPv4")
> Fixes: ad1e46a83716 ("ipv6: process socket-level control messages in IPv6")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
