From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 22:26:59 -0400 (EDT)
Message-ID: <20111013.222659.12182837968152363.davem@davemloft.net>
References: <1318545567.2533.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab1JNC1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 22:27:16 -0400
In-Reply-To: <1318545567.2533.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Oct 2011 00:39:27 +0200

> Add a 'truesize' argument to niu_rx_skb_append(), filled with rcr_size
> by the caller to properly account frag sizes in skb->truesize
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Please David double check this one as I am not very familiar with NIU
> code. Thanks !

It looks perfect!  And if it's not I'll soon find out :-)

Applied.
