From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] udp: support SO_PEEK_OFF
Date: Tue, 05 Apr 2016 16:29:54 -0400 (EDT)
Message-ID: <20160405.162954.391780099354812219.davem@davemloft.net>
References: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samanthakumar@google.com,
	edumazet@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933626AbcDEU34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:29:56 -0400
In-Reply-To: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue,  5 Apr 2016 12:41:13 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Support peeking at a non-zero offset for UDP sockets. Match the
> existing behavior on Unix datagram sockets.
> 
> 1/3 makes the sk_peek_offset functions safe to use outside locks
> 2/3 removes udp headers before enqueue, to simplify offset arithmetic
> 3/3 introduces SO_PEEK_OFFSET support, with Unix socket peek semantics.
> 
> Changes
>   v1->v2
>     - squash patches 3 and 4

Series applied, thanks Willem.
