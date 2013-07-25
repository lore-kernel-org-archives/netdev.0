From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Wed, 24 Jul 2013 20:08:51 -0700
Message-ID: <1374721731.1924.34.camel@joe-AO722>
References: <b939bb41630693171771c108801c1c5f688ecabc.1374525261.git.dvhart@linux.intel.com>
	 <cover.1374525261.git.dvhart@linux.intel.com>
	 <79241b53ec4e638008ba3384958ef9901ad11338.1374525261.git.dvhart@linux.intel.com>
	 <20130724.170008.924195436945641752.davem@davemloft.net>
	 <1374711603.3436.246.camel@dvhart-mobl1.amr.corp.intel.com>
	 <1374712895.1924.13.camel@joe-AO722>
	 <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hpa@zytor.com, peter.p.waskiewicz.jr@intel.com,
	andriy.shevchenko@linux.intel.com
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40288 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753054Ab3GYDIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 23:08:53 -0400
In-Reply-To: <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 19:58 -0700, Darren Hart wrote:
> On Wed, 2013-07-24 at 17:41 -0700, Joe Perches wrote:
> > On Wed, 2013-07-24 at 17:20 -0700, Darren Hart wrote:
> > > Ah, thanks. Leftover from a more complex driver_data with pointers to
> > > these functions. I'll fix and resubmit this patch alone as V3.
> > > Otherwise, no objections?
> > 
> > Only small nit is not using kernel-doc for this bit below:
[]
> I was following the existing style of the file (with the exception of
> the leading two ** as checkpatch complains. I thought erring on the side
> of consistency was the best course of action here. What would you
> suggest is the preferred approach here?

Hi Darren.

I hadn't actually looked at the rest of the unpatched
file.  If what you did is the same style, it's fine.

It just looked like you were trying to use kernel-doc
formatting style but not using it quite correctly.

> > On Mon, 2013-07-22 at 14:41 -0700, Darren Hart wrote:
> > > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> > > []
> > > +/* pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
> > > + * @hw:	            Pointer to the HW structure
> > > + * Returns
> > > + *	0:		Successful.
> > > + *	-EINVAL:	Invalid argument.
> > > + */

This bit in what I believe kernel-doc style is would
look like:

/**
 * pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
 * @hw:		Pointer to the HW structure
 *
 * Return:	O: Successful
 *		-EINVAL: Invalid argument
 */
