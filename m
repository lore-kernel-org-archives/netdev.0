From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 6 Feb 2005 23:24:50 +0100
Message-ID: <20050206222450.GX31837@postel.suug.ch>
References: <1107719343.1055.22.camel@jzny.localdomain> <20050206212928.GV31837@postel.suug.ch> <1107726133.1055.34.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107726133.1055.34.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1107726133.1055.34.camel@jzny.localdomain> 2005-02-06 16:42
> On Sun, 2005-02-06 at 16:29, Thomas Graf wrote:
> 
> > assign filters attached to it, i.e. listing filters based on
> > parent == XX: && dev == %DEV will result in the filters being listed
> > for both the qdisc and the class. I haven't found a fix that wouldn't
> > break many scripts so if you have a good idea, go ahead. ;->
> 
> I cant say ive run into this one - mostly i attach filters to root.
> Example script?

See the post as reply to Patick's comment. You won't notice it in
tc because it doesn't output complete trees.

> BTW, cycles allow me to work on the eaction stuff today. So far
> ive come to the conclusion that whats really needed to simplify
> writting some actions is to just provide generic methods they
> can use without them necessarily knowing details. I hope to test
> later on, maybe write a simple action and its user apce piece, and post
> patch.

Sounds good, I've been mostly occupied by writing a API documentation
to libnl and clean it up which almost doubled its usefulnes. There
is still some effort to go into the core to make it easier to use for
applications needing non blocking sockets or weird multiplexing. 

The traffic control part is slowly evoling but it take some more time
to implement all the remaining qdiscs and classifiers. A bit of luck
allowed me to provide a XML based external interface to other
applications. It should be easy to extend it to make it bidirectional
and get distributed configuration via some kind of existing or
new protocol. The most problematic issue remaining is byte ordering.
I guess I will end up having all the modules define their part of
the grammar specifying the required byte order of every field and
have a generic parser to do transformations as necessary.
