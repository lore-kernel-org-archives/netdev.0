From: James Morris <jmorris@intercode.com.au>
Subject: Re: how to report network device errors to userspace?
Date: Thu, 20 Jun 2002 12:44:49 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0206201238360.32372-100000@blackbird.intercode.com.au>
References: <20020619235406.A11706@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
   Donald Becker <becker@scyld.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020619235406.A11706@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Wed, 19 Jun 2002, Andi Kleen wrote:

> On Wed, Jun 19, 2002 at 05:44:05PM -0400, Chris Friesen wrote:
> > Andi Kleen wrote:
> > 
> > > I would suggest sending a netlink message from the driver.  That's really
> > > what netlink was designed for.
> > 
> > Can you point me to a driver that's done this cleanly as an example to follow?
> 
> Not exactly a driver, but you can e.g. look at the ip_queue netfilter 
> module.
> 

It's not a very clean example at this stage, unfortunately, as it contains 
some fairly ugly logic for maintaining unicast sessions.

If you don't specifically need unicast Netlink (which I don't think you 
do), try also looking at the tcpdiag & ctnetlink code.


- James
-- 
James Morris
<jmorris@intercode.com.au>
