From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Mon, 7 Jun 2004 14:46:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607144654.540e7eee@dell_ss3.pdx.osdl.net>
References: <20040608071252.77f9d69e.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, Gary.Spiess@Intermec.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
In-Reply-To: <20040608071252.77f9d69e.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Jun 2004 07:12:52 +0930
Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org> wrote:

> Hi Manfred, Gary, Stephen,
> 
> "But: I'm not sure that the change is required. What about just
> setting the mac to 0, and the actual mac address is set from user
> space? It's possible to set the mac address with"
> 
> Could I suggest if this is the solution implemented, setting the
> first octet of the MAC address to 0x02, as in a Locally Assigned
> MAC address ?
> 
> If an interface with an all zero's MAC address is added to a
> bridge, running the Spanning Tree Protocol (STP), it will always
> attempt to take over as the root bridge, unless STP root bridge
> priorities are being used. This would disrupt traffic on the
> attached LAN.

Actually, it won't let you add any interface to a bridge without
a valid ether address now (ie non-zero and not multicast).

> Ideally, assigning "zero" a MAC address which has almost no
> chance of disrupting STP or any other protocol could be useful.
> Maybe fe:ff:ff:ff:ff:ff ?
> 
> I think this would fit in with the "be conservative in what you
> send, liberal in what you receive" philosophy.
> 
> Regards,
> Mark.
> 
> ps, please CC on any replies, I'm not subscribed to the list yet.
