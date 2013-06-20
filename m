From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 20 Jun 2013 20:53:25 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E4168533FA5@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130619114009.1d4ece23@samsung-9>
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
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48068 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935359Ab3FTUxq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 16:53:46 -0400
In-Reply-To: <20130619114009.1d4ece23@samsung-9>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, June 19, 2013 11:40 AM
>
> On Thu, 13 Jun 2013 20:55:17 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > +
> > +/**
> > + * i40e_set_settings - Set Speed and Duplex
> > + * @netdev: network interface device structure
> > + * @ecmd: ethtool command
> > + *
> > + * Set speed/duplex per media_types advertised/forced
> > + **/
> > +static int i40e_set_settings(struct net_device *netdev,
> > +			     struct ethtool_cmd *ecmd)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> > +
> 
> Stub not needed, if ethtool_ops.set_settings is NULL, then
> ethtool_set_settings
> will do this for you.

Thanks,
sln
