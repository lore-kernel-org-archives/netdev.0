From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 20 Jul 2012 18:42:26 +0100
Message-ID: <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>
		<5005D45D.1040302@genband.com>
	 <20120717.141153.46613285253481776.davem@davemloft.net>
	 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	David Miller <davem@davemloft.net>, <yuvalmin@broadcom.com>,
	<gregory.v.rose@intel.com>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>
To: Don Dutile <ddutile@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <50097FBD.9080202@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-20 at 11:56 -0400, Don Dutile wrote:
> On 07/20/2012 11:27 AM, Chris Friesen wrote:
> > On 07/17/2012 03:11 PM, David Miller wrote:
> >> From: Chris Friesen<chris.friesen@genband.com>
> >> Date: Tue, 17 Jul 2012 15:08:45 -0600
> >>
> >>> From that perspective a sysfs-based interface is ideal since it is
> >>> directly scriptable.
> >>
> >> As is anything ethtool or netlink based, since we have 'ethtool'
> >> and 'ip' for scripting.
> >
> > I'm not picky...whatever works.
> >
> > To me the act of creating virtual functions seems generic enough (I'm aware of SR-IOV capable storage controllers, I'm sure there is other hardware as well) that ethtool/ip don't really seem like the most appropriate tools for the job.
> >
> Yes, and then there are 'other network' controllers too ... IB  which
> I don't know if it adheres to ethtool, since it's not an Ethernet
> device ... isn't that why they call it Infiniband ... ;-) )
> In the telecom space, they use NTBs and PCI as a 'network' ... I know,
> not common in Linux space, and VFs in that space aren't being
> discussed (that I've ever heard), but another example where
> 'network' != Ethernet, so ethtool doesn't solve PCI-level
> configuration/use.
[...]

The ethtool API is typically used for net device operations that can be
largely devolved to individual drivers, and which the network stack can
mostly ignore (though offload features are an historical exception to
this).  It started with Ethernet link settings, but many operations are
applicable (and implemented by) other types of network device.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
