From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: TOE brain dump
Date: 05 Aug 2003 11:25:57 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m1ptjkuica.fsf@frodo.biederman.org>
References: <20030802140444.E5798@almesberger.net> <3F2BF5C7.90400@us.ibm.com>
	<3F2C0C44.6020002@pobox.com> <20030802184901.G5798@almesberger.net>
	<m1fzkiwnru.fsf@frodo.biederman.org>
	<20030804162433.L5798@almesberger.net>
	<20030804122632.65ba2122.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Werner Almesberger <werner@almesberger.net>
	  jgarzik@pobox.com,
   niv@us.ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030804122632.65ba2122.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

> On Mon, 4 Aug 2003 16:24:33 -0300
> Werner Almesberger <werner@almesberger.net> wrote:
> 
> > Eric W. Biederman wrote:
> > > There is one place in low latency communications that I can think
> > > of where TCP/IP is not the proper solution.  For low latency
> > > communication the checksum is at the wrong end of the packet.
> > 
> > That's one of the few things ATM's AAL5 got right.
> 
> Let's recall how long the IFF_TRAILERS hack from BSD :-)

Putting the variable length headers on the end of a packet?  Or
was that something other than RFC893?

I think IPv6 solves that much more cleanly by simply deleting them.

> > But in the end, I think it doesn't really matter.
> 
> I tend to agree on this one.
> 
> And on the transmit side if you have more than 1 pending TX frame, you
> can always be prefetching the next one into the fifo so that by the
> time the medium is ready all the checksum bits have been done.

For large data transmissions that happens.
 
> In fact I'd be surprised if current generation 1g/10g cards are not
> doing something like this.

Well at this point before I propose anything concrete I suspect I need
to profile some actual application and see how things go.  But from a
very latency sensitive perspective, I would be surprised if the
problem goes away with faster technology.

For now I am happy just to insert the peculiar thought that latency
across the entire cluster/lan is of great importance to some
applications.

Eric
