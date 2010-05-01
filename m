From: David Miller <davem@davemloft.net>
Subject: Re: OFT - reserving CPU's for networking
Date: Sat, 01 May 2010 16:29:49 -0700 (PDT)
Message-ID: <20100501.162949.163246592.davem@davemloft.net>
References: <20100501105304.GA9434@gargoyle.fritz.box>
	<20100501.150338.93457735.davem@davemloft.net>
	<20100501225815.GA8074@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502Ab0EAX3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 19:29:44 -0400
In-Reply-To: <20100501225815.GA8074@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 2 May 2010 00:58:15 +0200

>> We're tracking flow cpu location state at the socket operations, like
>> recvmsg() and sendmsg(), where it belongs.
>> 
>> Would you like us to call into the card drivers and firmware at these
>> spots instead?
> 
> No, that's not needed for lazy flow tracking like in netfilter or 
> some NICs, it doesn't need exact updates. It just works with seen network 
> packets. 

Well what we need is exact flow updates so that we steer packets
to where the applications actually are.

Andi, this discussion is going in circles, can I just say "yeah you're
right Andi" and this will satisfy your desire to be correct and we can
be done with this?

Thanks.
