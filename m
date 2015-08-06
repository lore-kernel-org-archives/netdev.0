From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net-next 07/15] i40e/i40evf: Add TX/RX outer UDP checksum
 support for X722
Date: Wed, 5 Aug 2015 17:38:30 -0700
Message-ID: <20150805173830.00001a1c@unknown>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1438818735-38115-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S37TdC_ykVSi2SfLpX8TyNDs+XAgOxQzxgK-x8dKzb_nAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	<nhorman@redhat.com>, <sassmann@redhat.com>, <jogreene@redhat.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	jesse.brandeburg@intel.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42826 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbbHFAib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 20:38:31 -0400
In-Reply-To: <CALx6S37TdC_ykVSi2SfLpX8TyNDs+XAgOxQzxgK-x8dKzb_nAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Aug 2015 17:13:21 -0700
Tom Herbert <tom@herbertland.com> wrote:

> On Wed, Aug 5, 2015 at 4:52 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Anjali Singhai Jain <anjali.singhai@intel.com>
> >                 if (vsi->back->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
> >                         tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
> > +               if (vsi->back->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
> > +                       tx_ring->flags |= I40E_TXR_FLAGS_OUTER_UDP_CSUM;
> 
> Just curious... is there a difference between enabling the outer UDP
> checksum (of a tunnel) and just enabling checksum offload for UDP
> packets?

Yes, the hardware knows the difference (or we actually tell it
the difference) between a UDP packet and a tunnel inside a UDP
packet.
