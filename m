From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: OFT - reserving CPU's for networking
Date: Sun, 02 May 2010 00:44:17 +0100
Message-ID: <1272757457.27948.27.camel@localhost>
References: <20100430210131.GA2833@gargoyle.fritz.box>
	 <20100430.153038.62351857.davem@davemloft.net>
	 <20100501105304.GA9434@gargoyle.fritz.box>
	 <20100501.150338.93457735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, tglx@linutronix.de, shemminger@vyatta.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48154 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab0EBAbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 20:31:25 -0400
In-Reply-To: <20100501.150338.93457735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-01 at 15:03 -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Sat, 1 May 2010 12:53:04 +0200
> 
> >> And we don't want it to, because the decision mechanisms for steering
> >> that we using now are starting to get into the stateful territory and
> >> that's verbotton for NIC offload as far as we're concerned.
> > 
> > Huh? I thought full TCP offload was forbidden?[1] Statefull as in NIC 
> > (or someone else like netfilter) tracking flows is quite common and very far 
> > from full offload. AFAIK it doesn't have near all the problems full
> > offload has.
> 
> We're tracking flow cpu location state at the socket operations, like
> recvmsg() and sendmsg(), where it belongs.
> 
> Would you like us to call into the card drivers and firmware at these
> spots instead?

I'm interested in experimenting with this at some point, since our
hardware supports a fairly large number of filters that could be used
for it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

