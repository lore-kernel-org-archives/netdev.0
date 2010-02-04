From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Thu, 4 Feb 2010 13:26:11 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1002041325210.27432@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100204074811.16559.84676.stgit@localhost.localdomain>
 <20100204.091854.24215476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10996 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab0BDV0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 16:26:12 -0500
In-Reply-To: <20100204.091854.24215476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Feb 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 03 Feb 2010 23:48:13 -0800
> 
> > +#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
> > +	struct list_head list;
> > +};
> 
> You can't do this.
> 
> You put the list_head here in the kernel header, which BTW can
> be used by userspace too, and then you elide it in the
> ethtool utility copy of the header.
> 
> Use an encapsulator if you must inside of the kernel, but keep the
> userspace visible data structure clean of RCU and list_head
> kernel datastructures.

Ok.  I'll respin this asap.  Thanks for the quick review Dave.

-PJ
