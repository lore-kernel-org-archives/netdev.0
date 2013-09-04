From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next v3 1/8] i40e: main driver core
Date: Wed, 4 Sep 2013 00:59:13 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C61C0CE@FMSMSX102.amr.corp.intel.com>
References: <1377866347-23846-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <1377880368.2070.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62116 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761461Ab3IDA7Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 20:59:16 -0400
In-Reply-To: <1377880368.2070.26.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, August 30, 2013 9:33 AM
> 

Hi Joe, thanks for your comments, and we're working through another version to be posted Real Soon.  In the meantime I thought I'd respond to a couple specific comments.

> > +#define DRV_KERN "-k"
> > +
> > +#define DRV_VERSION_MAJOR 0
> > +#define DRV_VERSION_MINOR 3
> > +#define DRV_VERSION_BUILD 8
> > +#define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
> > +	     __stringify(DRV_VERSION_MINOR) "." \
> > +	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
> 
> does "-k" add/signify anything useful?

The "-k" helps us to quickly spot that a customer is asking us about the upstream version of our driver and not an out-of-tree (e.g. SourceForge) version.

[...]


> 
> > +/**
> > + * i40e_get_netdev_stats_struct - Get statistics for netdev interface
> > + * @netdev: network interface device structure
> > + *
> > + * Returns the address of the device statistics structure.
> > + * The statistics are actually updated from the service task.
> > + **/
> > +static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
> > +					     struct net_device *netdev,
> > +					     struct rtnl_link_stats64 *storage)
> 
> An alternative bsd declaration style might be
> more readable for these very long types and names.
> 
> static struct rtnl_link_stats64 *
> i40e_get_netdev_stats_struct(struct net_device *netdev,
> 			     struct rtnl_link_stats64 *storage)

We're trying to stay consistent in kernel function styles, stay within standard checkpatch restrictions, and keep the code readable and maintainable, which all together make for some difficult choices.  No matter which way we go on some of these decisions, we run into the painfully gray opinion areas of how someone else might have solved the problems.

sln
