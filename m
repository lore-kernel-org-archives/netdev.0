From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Intel and TOE in the news
Date: Wed, 2 Mar 2005 14:48:24 +0100
Message-ID: <20050302134824.GA20304@xi.wantstofly.org>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050219041007.GA17896@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 05:10:07AM +0100, Lennert Buytenhek wrote:

> > Intel plans to sidestep the need for separate TOE cards by building this 
> > technology into its server processor package - the chip itself, chipset 
> > and network controller. This should reduce some of the time a processor 
> > typically spends waiting for memory to feed back information and improve 
> > overall application processing speeds.
> 
> I wonder if they could just take the network processing circuitry from
> the IXP2800 (an extra 16-core (!) RISCy processor on-die, dedicated to
> doing just network stuff, and a 10gbps pipe going straight into the CPU
> itself) and graft it onto the Xeon.

It indeed appears to be something like the IXP2000.

	http://www.intel.com/technology/ioacceleration/index.htm

Quote from ServerNetworkIOAccel.pdf (which is otherwise content-free):

	Lightweight Threading

	[...] Rather than providing multiple hardware contexts in a
	processor like Hyper-Threading (HT) Technology from Intel, a
	single hardware context contains the network stack with
	multiple software-controlled threads.  When a packet
	thread triggers a memory event a scheduler within the network
	stack selects an alternate packet thread and loads the CPU
	execution pipeline. Porcessing continues in the shadow of a
	memory access. [...] Stall conditions, triggered by requests
	to slow memory devices, are nearly eliminated.

They can also DMA packet headers straight into L1/L2 ('Direct Cache
Access', innovation!), just like other products have been able to do
for ages now.

Not much other details up yet.


--L
