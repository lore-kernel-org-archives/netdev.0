From: Andi Kleen <ak@suse.de>
Subject: Re: looking for help with scanning of IPv6 interfaces
Date: Fri, 15 Nov 2002 23:52:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021115235200.B8265@wotan.suse.de>
References: <20021115200051.A14677@wotan.suse.de> <Pine.LNX.4.44.0211151737010.6439-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Michael Richardson <mcr@sandelman.ottawa.on.ca>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0211151737010.6439-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Physical devices are read using /proc/net/dev
> ...
> > That is the old fashioned way.
> >  
> > The new fashioned one is to query them using rtnetlink. You use a RTM_GETADDR
> > NLM_F_REQUEST query with wildcard (NLM_F_ROOT) to get a full list.
> > See the netlink,rtnetlink, libnetlink manpages and iproute2 as an example. 
> > It is easier when you use libnetlink.
> 
> Do you have a snippet of code?

Check iproute2 or zebra source. iproute2 has a libnetlink which is quite useful.

I also wrote some manpages (netlink(3),netlink(7),rtnetlink(7) etc, but 
admittedly they are not very good) 

> What kernel version does this start working?

Somewhere in Linux 2.1.<late number> 
> 
> Of course for code that needs to work with already deployed systems, you
> need to have code for the old method around anyway...

Only when you still want to support 2.0. Ok some people do not enable
netlink in their kernel configuration, but many modern distributions
require it for booting now (because the network init scripts use iproute2),
so this shouldn't be a big issue anymore.

-Andi
