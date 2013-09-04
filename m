From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 1/8] i40e: main driver core
Date: Tue, 03 Sep 2013 18:35:50 -0700
Message-ID: <1378258550.7347.52.camel@joe-AO722>
References: <1377866347-23846-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377880368.2070.26.camel@joe-AO722>
	 <FC41C24E35F18A40888AACA1A36F3E416C61C0CE@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36508 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761568Ab3IDBfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 21:35:52 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E416C61C0CE@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 00:59 +0000, Nelson, Shannon wrote:
> > -----Original Message-----
> > From: Joe Perches [mailto:joe@perches.com]
[]
> Hi Joe,

Hi again.

> > > +/**
> > > + * i40e_get_netdev_stats_struct - Get statistics for netdev interface
> > > + * @netdev: network interface device structure
> > > + *
> > > + * Returns the address of the device statistics structure.
> > > + * The statistics are actually updated from the service task.
> > > + **/
> > > +static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
> > > +					     struct net_device *netdev,
> > > +					     struct rtnl_link_stats64 *storage)
> > 
> > An alternative bsd declaration style might be
> > more readable for these very long types and names.
> > 
> > static struct rtnl_link_stats64 *
> > i40e_get_netdev_stats_struct(struct net_device *netdev,
> > 			     struct rtnl_link_stats64 *storage)
> 
> We're trying to stay consistent in kernel function styles, stay within
> standard checkpatch restrictions, and keep the code readable and
> maintainable, which all together make for some difficult choices.  No
> matter which way we go on some of these decisions, we run into the
> painfully gray opinion areas of how someone else might have solved the
> problems.

No worries.  Whatever you choose to do will be OK.

The BSD declaration style is pretty common in the
kernel tree too though.

Another thing would be to mark various arguments const struct
in the prototypes and declarations instead of just struct.

cheers, Joe
