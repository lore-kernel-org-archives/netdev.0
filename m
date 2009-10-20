From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Mon, 19 Oct 2009 21:21:07 -0700 (PDT)
Message-ID: <20091019.212107.81347219.davem@davemloft.net>
References: <20091019.205948.193706797.davem@davemloft.net>
	<4ADD3794.8030906@gmail.com>
	<4ADD3982.2040100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51784
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750781AbZJTEUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:20:44 -0400
In-Reply-To: <4ADD3982.2040100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 06:16:02 +0200

> BTW, even an insertion can crash a lockless reader, since reader
>  could see a corrupt n->next (hlist_add_head() has no barrier
>  between n->next = first and h->first = n;)

Ok, now that convinces it for me, I'll apply your patch, thanks!
