From: greg chesson <greg@atheros.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 07 Sep 2004 11:14:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413DFA79.501@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>	<757AB580-0030-11D9-9224-000A95AD0668@errno.com>	<20040906182328.08faf843.davem@davemloft.net>	<200409062132.49356.sam@errno.com>	<413DE9ED.30300@atheros.com> <20040907101027.7547e591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sam@errno.com, vda@port.imtp.ilyichevsk.odessa.ua, jgarzik@pobox.com,
        netdev@oss.sgi.com, acx100-devel@lists.sourceforge.net,
        jt@bougret.hpl.hp.com, jkmaline@cc.hut.fi, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040907101027.7547e591.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I certainly agree with you about getting the base design right.
Where are these bits you refer to?

g

David S. Miller wrote:
> On Tue, 07 Sep 2004 10:03:41 -0700
> greg chesson <greg@atheros.com> wrote:
> 
> 
>>What about eth_type_trans()?
> 
> 
> It determines the protocol type from the ethernet header
> fields.  It is a simple shorthand header field fetcher,
> not a protocol stack.
> 
> You would need a eth80211_type_trans() for wireless
> drivers too, and surprise surprise my skeleton 802.11
> stack code in fact does exactly this.
> 
> 
>>I've thought about this problem and don't think there is a good answer
>>if a layered approach to protocol implementation stipulates that each layer
>>be self-contained.
> 
> 
> In my 802.11 stack the 802.11 information structure can be
> found given a generic device pointer.  All the wireless info
> can be retrieved from that, and you can use it to call the
> wireless stack routines if you wish as well.
> 
> This is no different than how we keep ipv4 information hooked
> onto the generic device structure and walk between these various
> entities in the ipv4 and generic networking code.
> 
> Please read my skeletal stack code, it is exactly how I truly
> believe something like this should be architected.  It's all
> the base layout stuff that's important, the rest are details
> that will fit in cleanly and readily once you have a solid
> and firm foundation.
> 
