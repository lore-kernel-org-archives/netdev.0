From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: netif_rx_schedule_prep() returning false?
Date: Wed, 02 Feb 2005 11:16:32 -0800
Message-ID: <1107371791.3366.126.camel@sfeldma-mobl.dsl-verizon.net>
References: <7bca1cb5050202100475279073@mail.gmail.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb5050202100475279073@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-02 at 10:04, Asim Shankar wrote:
> Specifically, in e1000 driver, when loaded with TxIntDelay=0,
> RxIntDelay=0, InterruptThrottleRate=0 (i.e., no hardware
> interrupt-coalescing), I've observed that the call to
> netif_rx_schedule_prep() in the interrupt handler (e1000_intr())
> ocassionally returns false. Further investigation shows that this is
> because the __LINK_STATE_RX_SCHED bit of the struct net_device's state
> is already set (netif_running(dev) is always true). I also checked the
> interrupt cause register (ICR) in the interrupt handler and it seems
> the interrupts were caused by packet receives (ICR == E1000_ICR_RXT0,
> no other bits in the ICR register were set), which by my understanding
> should have not been possible.

I'm running the same setup with delays turned off and I'm not seeing
what you're seeing.  What e1000 controller are you using?  Send lspci
-n.

-scott
