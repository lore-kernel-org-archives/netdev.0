From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Wed, 2 Mar 2005 09:34:58 -0800
Message-ID: <200503021735.j22HZuDD020120@guinness.s2io.com>
References: <20050302134824.GA20304@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@oss.sgi.com>
To: "'Lennert Buytenhek'" <buytenh@wantstofly.org>,
        "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <20050302134824.GA20304@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Lennert Buytenhek
> Sent: Wednesday, March 02, 2005 5:48 AM
> To: Jeff Garzik
> Cc: Netdev
> Subject: Re: Intel and TOE in the news
> 
> On Sat, Feb 19, 2005 at 05:10:07AM +0100, Lennert Buytenhek wrote:
> 
> > > Intel plans to sidestep the need for separate TOE cards 
> by building 
> > > this technology into its server processor package - the 
> chip itself, 
> > > chipset and network controller. This should reduce some 
> of the time 
> > > a processor typically spends waiting for memory to feed back 
> > > information and improve overall application processing speeds.
> > 
> > I wonder if they could just take the network processing 
> circuitry from 
> > the IXP2800 (an extra 16-core (!) RISCy processor on-die, 
> dedicated to 
> > doing just network stuff, and a 10gbps pipe going straight into the 
> > CPU
> > itself) and graft it onto the Xeon.
> 
> It indeed appears to be something like the IXP2000.
> 
> 	http://www.intel.com/technology/ioacceleration/index.htm
> 
> Quote from ServerNetworkIOAccel.pdf (which is otherwise content-free):
> 
> 	Lightweight Threading
> 
> 	[...] Rather than providing multiple hardware contexts in a
> 	processor like Hyper-Threading (HT) Technology from Intel, a
> 	single hardware context contains the network stack with
> 	multiple software-controlled threads.  When a packet
> 	thread triggers a memory event a scheduler within the network
> 	stack selects an alternate packet thread and loads the CPU
> 	execution pipeline. Porcessing continues in the shadow of a
> 	memory access. [...] Stall conditions, triggered by requests
> 	to slow memory devices, are nearly eliminated.
> 
> They can also DMA packet headers straight into L1/L2 ('Direct 
> Cache Access', innovation!), just like other products have 
> been able to do for ages now.
> 
> Not much other details up yet.

It was a good presentation, I suspect some/most of you guys may be able to
get it through your company attendees. At any rate, don't worry - details
will probably come out soon enough since kernel support should be a "must
have" for the entire concept to work :-) 

On the NIC side, I suspect we will not see much in I/O AT GbE comparing to
what we are already shipping as 10GbE Xframe ASIC features (header
separation for potential prefetching, stateless/state aware offloads, etc.)
- the feat would be to make these assists a de-facto standard (so both NIC
vendors and kernel developers have motivation to support'em) and fully
utilize them by integrating with the rest of the hw/OS in the system; 
I'm actually very happy to see Intel pushing this ... 

Leonid 
  

> 
> 
> --L
> 
> 
