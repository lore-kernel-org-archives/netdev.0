From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock_diag: do not broadcast raw socket destruction
Date: Tue, 28 Jun 2016 09:09:33 -0400 (EDT)
Message-ID: <20160628.090933.2110451603920060165.davem@davemloft.net>
References: <1466798555-40125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kraig@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbcF1NKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:10:16 -0400
In-Reply-To: <1466798555-40125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 24 Jun 2016 16:02:35 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Diag intends to broadcast tcp_sk and udp_sk socket destruction.
> Testing sk->sk_protocol for IPPROTO_TCP/IPPROTO_UDP alone is not
> sufficient for this. Raw sockets can have the same type.
> 
> Add a test for sk->sk_type.
> 
> Fixes: eb4cb008529c ("sock_diag: define destruction multicast groups")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.
