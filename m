From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Tue, 20 May 2003 08:14:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520080940.E40885@shell.cyberus.ca>
References: <1053313298.3909.5.camel@rth.ninka.net> <20030519202756.I39498@shell.cyberus.ca>
 <3EC9B815.4000504@ethanet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ethan Sommer <sommere@ethanet.com>
In-Reply-To: <3EC9B815.4000504@ethanet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, Ethan Sommer wrote:

> I picked Spencer's mainly because it was a pain to port the glibc
> version into kernel space. They are both basically the posix regexp
> interface, so if someone wants to get another version working in kernel
> space we can test and see which one performs better with real load
> pretty easily.
>

Take a look at snorts implementation. I think snort is GPL so you may
just be able to borrow it.

>
> Yep. We haven't spent a lot of time on optimizations. Obviously that
> example can be fixed pretty quickly... except I'm not sure we can avoid
> it and stay thread safe? (linux can route multiple packets at the same
> time on an smp box right? so we can't just use a staically defined
> buffer...)
>

Your problem seesm to be the regexp scheme used. You dont need a static
buffer i think. You should be able to operate on an incoming packet
itself.

cheers,
jamal
