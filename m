From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 1/4] net: Add support to netdev ops for changing
 hardware queue MAC and VLAN filters
Date: Tue, 1 Dec 2009 09:57:51 +1100
Message-ID: <20091130225751.GI11152@verge.net.au>
References: <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
 <1258657155.2837.10.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A200AD@rrsmsx501.amr.corp.intel.com>
 <1258982570.2845.8.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A9617F@rrsmsx501.amr.corp.intel.com>
 <20091130060323.GA17989@verge.net.au>
 <EA929A9653AAE14F841771FB1DE5A1365FA6BFA040@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53560 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbZK3W5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:57:45 -0500
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA6BFA040@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 11:36:08AM -0700, Williams, Mitch A wrote:
> >From: Simon Horman [mailto:horms@verge.net.au]
> >Sent: Sunday, November 29, 2009 10:03 PM
> 
> >> The issue of which VF goes with which PF device can be deduced in
> >> userspace via sysfs.
> >
> >Does this mean that the configuration of filtering for a VF needs
> >to be done where the interface for the VF exists - e.g. in a KVM
> >guest/Xen domU?
> >
> 
> No, all of the configuration is done through the PF device.  What I was
> saying was that, given a specific VF PCI device (which would be passed
> through to the VM), you can use sysfs to determine which PF owns it, and
> then run the ip command to tell the PF to configure the VF.

Understood, sorry I missed that the first time around.

> >In terms of dealing with interfaces and the way that tools such as ip work
> >that makes a lot of sense. But I wonder if it actually makes more sense
> >from an administrative point of view to have this configuration go through
> >the PF - e.g. the KVM host/Xen domO.
> 
> >From a policy and security standpoint, you can't allow the VM to handle
> >its own hardware configuration. The host/hypervisor/VM Manager/boss has
> >to handle this or you lose many of the advantages of virtualization
> >(i.e. isolation, security, stability, etc).

Yes, agreed.
