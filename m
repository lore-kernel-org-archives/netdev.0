From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [patch] net: mv643xx_eth: potential NULL dereference in probe()
Date: Wed, 13 Nov 2013 11:00:54 -0700
Message-ID: <20131113180054.GA19645@obsidianresearch.com>
References: <20131113075247.GI25541@elgon.mountain>
 <52833734.5000507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:44937 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755654Ab3KMSA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 13:00:58 -0500
Content-Disposition: inline
In-Reply-To: <52833734.5000507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 09:24:20AM +0100, Sebastian Hesselbarth wrote:
> On 11/13/13 08:52, Dan Carpenter wrote:
> >We assume that "mp->phy" can be NULL a couple lines before the
> >dereference.
> >
> >Fixes: 1cce16d37d0f ('net: mv643xx_eth: Add missing phy_addr_set in DT mode')
> >Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Acked-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

My bad, I missed this possibility.

Jason
