From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Tue, 30 Nov 2004 07:48:23 +0100
Message-ID: <20041130064823.GA27872@xi.wantstofly.org>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041129172540.6b959858.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 05:25:40PM -0800, David S. Miller wrote:

> > For example, when transmitting 300-byte packets, I can TX 38261 packets
> > per second, but I should be able to TX ~38580.  When doing the math, it
> > turns out that 38261 is exactly the number of 302-byte packets you can
> > stuff into Fast Ethernet per second.
> 
> Is the packet length in those calculations taking into consideration
> the CRC et al. bytes that the card adds to the packet?

Yeah, preamble (8 bytes), CRC (4 bytes), inter-packet gap (12 bytes).

Perhaps the via-rhine simply can't send out packets back-to-back and
needs 14 byte times of inter-packet gap.  I couldn't find any stray +2
in the driver anywhere but I'm just checking.
