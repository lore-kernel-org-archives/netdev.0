From: Andi Kleen <andi@firstfloor.org>
Subject: Re: OFT - reserving CPU's for networking
Date: Sun, 2 May 2010 00:58:15 +0200
Message-ID: <20100501225815.GA8074@gargoyle.fritz.box>
References: <20100430210131.GA2833@gargoyle.fritz.box> <20100430.153038.62351857.davem@davemloft.net> <20100501105304.GA9434@gargoyle.fritz.box> <20100501.150338.93457735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54753 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab0EAWzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 18:55:46 -0400
Content-Disposition: inline
In-Reply-To: <20100501.150338.93457735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We're tracking flow cpu location state at the socket operations, like
> recvmsg() and sendmsg(), where it belongs.
> 
> Would you like us to call into the card drivers and firmware at these
> spots instead?

No, that's not needed for lazy flow tracking like in netfilter or 
some NICs, it doesn't need exact updates. It just works with seen network 
packets. 

-Andi
