From: Andrew Morton <akpm@osdl.org>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 19:17:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317191716.460836b0.akpm@osdl.org>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040317000048.10d9f52c.ak@suse.de>
	<20040316175052.556d5c22.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040316175052.556d5c22.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> wrote:
>
> On Wed, 17 Mar 2004 00:00:48 +0100
> Andi Kleen <ak@suse.de> wrote:
> 
> > iirc there was a 2.4 port of NistNet. Porting it to 2.6 is probably
> > not that much work.
> 
> nistnet works, but even akpm remembers it as pretty grotty, who knows
> maybe the most recent 2.4.x variant was much better, but I doubt it.

whaddya mean "even"?

I wrote a userspace thingy many moons ago which provides variable delays
and bandwidth restriction.  It's for simulating long, thin pipes.  It uses
the tap/tun interface to route packets up to userspace where the
delay/throttling is implemented.  It requires weird policy routing rules,
but there are scripts there which set everything up.

http://www.zipworld.com.au/~akpm/linux/patches/stuff/packet-delay.tar.gz
