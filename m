From: "David S. Miller" <davem@davemloft.net>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Mon, 29 Nov 2004 17:25:40 -0800
Message-ID: <20041129172540.6b959858.davem@davemloft.net>
References: <20041129222700.GA22918@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041129222700.GA22918@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Nov 2004 23:27:00 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> For example, when transmitting 300-byte packets, I can TX 38261 packets
> per second, but I should be able to TX ~38580.  When doing the math, it
> turns out that 38261 is exactly the number of 302-byte packets you can
> stuff into Fast Ethernet per second.

Is the packet length in those calculations taking into consideration
the CRC et al. bytes that the card adds to the packet?
