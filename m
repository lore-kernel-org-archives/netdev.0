From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Thu, 04 Feb 2010 15:07:50 -0800
Message-ID: <1265324870.2780.16.camel@localhost>
References: <20100204074811.16559.84676.stgit@localhost.localdomain>
	 <20100204.091854.24215476.davem@davemloft.net>
	 <Pine.WNT.4.64.1002041325210.27432@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B6B4B87.6020500@garzik.org> <1265323938.2780.6.camel@localhost>
	 <4B6B5077.9070005@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1508 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755823Ab0BDXHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 18:07:50 -0500
In-Reply-To: <4B6B5077.9070005@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-04 at 14:55 -0800, Jeff Garzik wrote:
> On 02/04/2010 05:52 PM, Peter P Waskiewicz Jr wrote:
> > On Thu, 2010-02-04 at 14:34 -0800, Jeff Garzik wrote:
> >> On 02/04/2010 04:26 PM, Waskiewicz Jr, Peter P wrote:
> >>> On Thu, 4 Feb 2010, David Miller wrote:
> >>>
> >>>> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> >>>> Date: Wed, 03 Feb 2010 23:48:13 -0800
> >>>>
> >>>>> +#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
> >>>>> +	struct list_head list;
> >>>>> +};
> >>>>
> >>>> You can't do this.
> >>>>
> >>>> You put the list_head here in the kernel header, which BTW can
> >>>> be used by userspace too, and then you elide it in the
> >>>> ethtool utility copy of the header.
> >>>>
> >>>> Use an encapsulator if you must inside of the kernel, but keep the
> >>>> userspace visible data structure clean of RCU and list_head
> >>>> kernel datastructures.
> >>>
> >>> Ok.  I'll respin this asap.  Thanks for the quick review Dave.
> >>
> >> Great.  I'll look for the updated userspace patch, too, and put it into
> >> the ethtool-2.6.34 pile (ie. ethtool-net-next).
> >>
> >
> > I didn't plan on respinning the userspace side.  I put a container
> > wrapped around the flow_spec struct to do the list management in the
> > kernel.  This shouldn't need a change to userspace.
> 
> Well, I figured there would be some trivial tweaks and patch offsets, 
> because we want to keep the kernel ethtool.h and userspace 
> ethtool-copy.h headers in sync.
> 
> Either way, no big deal.  I'll make sure net-next and ethtool match up, 
> after your userspace patch is applied, one way or the other.

Well, my "fixing" of the kernel side will make the structures align now.

Thanks for staying on top of this though.  :-)

-PJ

