From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] vlan ioctl propagation (rev.2)
Date: Mon, 9 Aug 2004 08:53:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809085348.11eaa869@dell_ss3.pdx.osdl.net>
References: <20040806091305.4d405664@dell_ss3.pdx.osdl.net>
	<20040806132145.675fd17d.davem@redhat.com>
	<20040806143928.711d92eb@dell_ss3.pdx.osdl.net>
	<20040807211036.GA7970@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040807211036.GA7970@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 7 Aug 2004 23:10:37 +0200
bert hubert <ahu@ds9a.nl> wrote:

> On Fri, Aug 06, 2004 at 02:39:28PM -0700, Stephen Hemminger wrote:
> > Here is a redo of the patch to propagate ethtool and mii ioctl's
> > on vlan's to the underlying real device.  This time the request
> > is copied to a new buffer, to avoid the colon name rewrite issues.
> 
> Is this really what we want? We also don't make virtual IPs appear as real
> interfaces anymore. Virtual devices are just that - virtual.
> 
> -- 
> http://www.PowerDNS.com      Open source, database driven DNS Software 
> http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO

The problem is that the bridge code (and bonding) want to be able to send ethtool
ioctl's to the device.  The bridge wants it to find out the speed of the device
to set the spanning tree values appropriately. 
I would rather not special case VLAN's.
