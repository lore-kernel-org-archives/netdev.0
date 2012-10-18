From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix FIONREAD/SIOCINQ
Date: Thu, 18 Oct 2012 15:36:39 -0400 (EDT)
Message-ID: <20121018.153639.105102863572041684.davem@davemloft.net>
References: <1350587652.32642.215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, enh@google.com, ncardwell@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074Ab2JRTgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:36:42 -0400
In-Reply-To: <1350587652.32642.215.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Oct 2012 21:14:12 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_ioctl() tries to take into account if tcp socket received a FIN
> to report correct number bytes in receive queue.
> 
> But its flaky because if the application ate the last skb,
> we return 1 instead of 0.
> 
> Correct way to detect that FIN was received is to test SOCK_DONE.
> 
> Reported-by: Elliot Hughes <enh@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
