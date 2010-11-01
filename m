From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Routing over multiple interfaces
Date: Mon, 01 Nov 2010 18:15:23 -0400
Message-ID: <1288649723.16155.1.camel@macbook.infradead.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <1288647330.2660.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	uweber@astaro.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53175 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab0KAWQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 18:16:07 -0400
In-Reply-To: <1288647330.2660.116.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-01 at 22:35 +0100, Eric Dumazet wrote:
> David W. probably wants to use teql or some bonding ?
> 
> # tc qdisc add dev ppp0 root teql0
> # tc qdisc add dev ppp1 root teql0
> # ip link set dev teql0 up
> # ip route add default src 90.155.92.214 dev teql0 

That looks very likely; thanks. I'll try it... but when I get home next
week, not from the wrong side of the Atlantic ;)

-- 
dwmw2

