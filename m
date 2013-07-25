From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH V2 net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Wed, 24 Jul 2013 19:58:14 -0700
Message-ID: <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
References: <b939bb41630693171771c108801c1c5f688ecabc.1374525261.git.dvhart@linux.intel.com>
	 <cover.1374525261.git.dvhart@linux.intel.com>
	 <79241b53ec4e638008ba3384958ef9901ad11338.1374525261.git.dvhart@linux.intel.com>
	 <20130724.170008.924195436945641752.davem@davemloft.net>
	 <1374711603.3436.246.camel@dvhart-mobl1.amr.corp.intel.com>
	 <1374712895.1924.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hpa@zytor.com, peter.p.waskiewicz.jr@intel.com,
	andriy.shevchenko@linux.intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43737 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668Ab3GYC6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 22:58:21 -0400
In-Reply-To: <1374712895.1924.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 17:41 -0700, Joe Perches wrote:
> On Wed, 2013-07-24 at 17:20 -0700, Darren Hart wrote:
> > Ah, thanks. Leftover from a more complex driver_data with pointers to
> > these functions. I'll fix and resubmit this patch alone as V3.
> > Otherwise, no objections?
> 
> Only small nit is not using kernel-doc for this bit below:

Hi Joe,

Thank you for the review.

I was following the existing style of the file (with the exception of
the leading two ** as checkpatch complains. I thought erring on the side
of consistency was the best course of action here. What would you
suggest is the preferred approach here?

> 
> On Mon, 2013-07-22 at 14:41 -0700, Darren Hart wrote:
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> > []
> > +/* pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
> > + * @hw:	            Pointer to the HW structure
> > + * Returns
> > + *	0:		Successful.
> > + *	-EINVAL:	Invalid argument.
> > + */
> 
> 
> 

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
