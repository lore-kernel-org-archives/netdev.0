From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 23 Jul 2004 20:49:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090630154.1134.6.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
	 <1090612669.1218.47.camel@jzny.localdomain>
	 <20040723135945.7f50b02c.davem@redhat.com>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040723135945.7f50b02c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



I will take care of it next week when i get back. 
If 2.6.8 is coming out before end of next week, i would suggest undoing
Stephens patch.
The way it was before was backward compatible as long as you dont
turn on those features; and those features all have a strong warning not
to turn them on unless you a new iproute2;-> And if you turn them on and
used my patches to tc all will work just fine ...

cheers,
jamal

On Fri, 2004-07-23 at 16:59, David S. Miller wrote:
> The current 2.6.x tree is obviously busted.
> 
> Can someone send me a patch soon'ish that does something
> about it, so that 2.6.8 doesn't go et with things
> like this?
> 
> Thanks.
