From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: avoid NULL deref in inet_ctl_sock_destroy()
Date: Mon, 02 Nov 2015 17:53:19 +0100
Message-ID: <1446483199.1604795.426897569.53235AF0@webmail.messagingengine.com>
References: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53423 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753545AbbKBQxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 11:53:20 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id ECAE9203E3
	for <netdev@vger.kernel.org>; Mon,  2 Nov 2015 11:53:19 -0500 (EST)
In-Reply-To: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 2, 2015, at 16:50, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Under low memory conditions, tcp_sk_init() and icmp_sk_init()
> can both iterate on all possible cpus and call inet_ctl_sock_destroy(),
> with eventual NULL pointer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Eric, was this a private report or some of those floating around
publicly?

Thanks,
Hannes
