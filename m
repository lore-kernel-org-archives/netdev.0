From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: 08 Sep 2004 03:38:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094628909.1097.145.camel@jzny.localdomain>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	 <757AB580-0030-11D9-9224-000A95AD0668@errno.com>
	 <20040906182328.08faf843.davem@davemloft.net>
	 <200409062132.49356.sam@errno.com> <413DE9ED.30300@atheros.com>
	 <20040907101027.7547e591.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greg chesson <greg@atheros.com>, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua, jgarzik@pobox.com,
        netdev@oss.sgi.com, acx100-devel@lists.sourceforge.net,
        jt@bougret.hpl.hp.com, jkmaline@cc.hut.fi, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040907101027.7547e591.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-07 at 13:10, David S. Miller wrote:
> On Tue, 07 Sep 2004 10:03:41 -0700
> greg chesson <greg@atheros.com> wrote:
> 
> > What about eth_type_trans()?
> 
> It determines the protocol type from the ethernet header
> fields.  It is a simple shorthand header field fetcher,
> not a protocol stack.
> 
> You would need a eth80211_type_trans() for wireless
> drivers too, and surprise surprise my skeleton 802.11
> stack code in fact does exactly this.

Or as Andi has been suggesting for sometime, not invoke it all ;->
This is possible if the DMA descriptor already has all the info
needed (quiet a few modern hardware can be programmed to do this).
.. er, at the driver level. So this is not "a gross input packet
hooked eater thing that's an ugly wart bolted onto the
side of the driver API.";->

cheers,
jamal
