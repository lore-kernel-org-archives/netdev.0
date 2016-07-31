From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: consider recv buf for the initial window
 scale
Date: Sat, 30 Jul 2016 21:22:21 -0700 (PDT)
Message-ID: <20160730.212221.1931517327013922175.davem@davemloft.net>
References: <1469799242-28408-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbcGaEWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 00:22:23 -0400
In-Reply-To: <1469799242-28408-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Fri, 29 Jul 2016 09:34:02 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> tcp_select_initial_window() intends to advertise a window
> scaling for the maximum possible window size. To do so,
> it considers the maximum of net.ipv4.tcp_rmem[2] and
> net.core.rmem_max as the only possible upper-bounds.
> However, users with CAP_NET_ADMIN can use SO_RCVBUFFORCE
> to set the socket's receive buffer size to values
> larger than net.ipv4.tcp_rmem[2] and net.core.rmem_max.
> Thus, SO_RCVBUFFORCE is effectively ignored by
> tcp_select_initial_window().
> 
> To fix this, consider the maximum of net.ipv4.tcp_rmem[2],
> net.core.rmem_max and socket's initial buffer space.
> 
> Fixes: b0573dea1fb3 ("[NET]: Introduce SO_{SND,RCV}BUFFORCE socket options")
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Suggested-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
