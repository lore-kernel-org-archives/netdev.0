From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Tue, 8 Jun 2004 07:41:05 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608074105.217ff66c.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20040608071252.77f9d69e.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<20040607144654.540e7eee@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, Gary.Spiess@Intermec.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040607144654.540e7eee@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 14:46:54 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Tue, 8 Jun 2004 07:12:52 +0930
> Mark Smith
> <random@72616e646f6d20323030342d30342d31360a.nosense.org>
> wrote:
> 
> > Hi Manfred, Gary, Stephen,
> > 

<snip>

> > If an interface with an all zero's MAC address is added to a
> > bridge, running the Spanning Tree Protocol (STP), it will
> > always attempt to take over as the root bridge, unless STP
> > root bridge priorities are being used. This would disrupt
> > traffic on the attached LAN.
> 
> Actually, it won't let you add any interface to a bridge
> without a valid ether address now (ie non-zero and not
> multicast).
> 

That's good, I first noticed this issue when I happened to add a
dummy interface into a bridge configuration, and found that its
zero MAC address ended up disrupting the spanning tree. 

I also have just noticed that the dummy interfaces now have
random MAC addresses as per the function you mentioned earlier.
Also good.

Regards,
Mark.

> > 
> > ps, please CC on any replies, I'm not subscribed to the list
> > yet.
