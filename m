From: Brad Hards <bhards@bigpond.net.au>
Subject: Re: PF_PACKET??
Date: Fri, 19 Apr 2002 11:19:54 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200204191119.55237.bhards@bigpond.net.au>
References: <Pine.LNX.4.33L2.0204181953230.30276-100000@pali.cps.cmich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-net-owner@vger.kernel.org>
To: Ish Rattan <ishwar@pali.cps.cmich.edu>, <linux-net@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.33L2.0204181953230.30276-100000@pali.cps.cmich.edu>
List-Id: netdev.vger.kernel.org

On Fri, 19 Apr 2002 09:56, Ish Rattan wrote:
> On Fri, 19 Apr 2002, Brad Hards wrote:
> > On Fri, 19 Apr 2002 02:13, Ish Rattan wrote:
> > > Does any one have a complete client/server type program or tutotial on
> > > using PF_PACKET to by pass the TCP/IP stack in the kernel? I can't seem
> > > to find a sample and hence subscribed to this list to ask for
> > > pointers.
> >
> > Possibly the wrong question. I take it that you want to avoid using the
> > kernel support for some reason, possibly portability. In that case, you
> > should consider a couple of libraries
>
> Well, I am more into implementation of TCP/IP stack in user mode (user
> level) for teaching aid in a graduate course in Computer Networks. I
> think that such a thing is possible and I am missing the starting point..
Probably possible (and I still think you'd be better off with those libraries, 
which are, after all, just access the packet filter sockets), but don't know 
if it is worth it. 
Why not use User-Mode Linux (http://user-mode-linux.sourceforge.net)?
You get the whole kernel, including the networking stack, running in 
user-space. You can run several virtual machines on one real host, and get to 
network between them in a couple of different ways. Might even be worth doing 
if you had your own user-space implementation of the stack, as the 
environment in which you run your implementation.


Brad
