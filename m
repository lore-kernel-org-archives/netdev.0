From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Intel and TOE in the news
Date: Sat, 19 Feb 2005 11:46:24 -0800
Message-ID: <20050219114624.373af63f.davem@davemloft.net>
References: <4216B62D.6000502@pobox.com>
	<20050219041007.GA17896@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050219041007.GA17896@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Feb 2005 05:10:07 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> On Fri, Feb 18, 2005 at 10:44:45PM -0500, Jeff Garzik wrote:
> 
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
> 
> Now _that_ would be something worth experiencing.

No, that would be garbage.

Read what they are doing.  The idea is not to have all of this network
protocol logic off-cpu, the idea is to "reduce some of the time
a processor typically spends waiting for memory to feed back information"

Think about what part of the network I/O equation that is working on.
It's not protocol offload, that's for sure.
