From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_make_synack() consumes dst parameter
Date: Mon, 04 Jun 2012 11:33:22 -0400 (EDT)
Message-ID: <20120604.113322.918242204991743428.davem@davemloft.net>
References: <1338791601.2760.1725.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2FDPdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:33:25 -0400
In-Reply-To: <1338791601.2760.1725.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Jun 2012 08:33:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_make_synack() clones the dst, and callers release it.
> 
> We can avoid two atomic operations per SYNACK if tcp_make_synack()
> consumes dst instead of cloning it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
