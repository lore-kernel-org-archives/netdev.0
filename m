From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Wed, 4 Aug 2010 16:56:00 +0900
Message-ID: <20100804075559.GB10740@verge.net.au>
References: <20100804104750.GA9652@pe-dt013.marvell.com>
 <20100804065818.GI21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sachin Sanap <ssanap@marvell.com>, netdev@vger.kernel.org,
	akarkare@marvell.com, sarnaik@marvell.com, eric.y.miao@gmail.com,
	prakity@marvell.com, markb@marvell.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55994 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab0HDH4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:56:09 -0400
Content-Disposition: inline
In-Reply-To: <20100804065818.GI21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 08:58:19AM +0200, Lennert Buytenhek wrote:
> On Wed, Aug 04, 2010 at 04:17:50PM +0530, Sachin Sanap wrote:

[snip]

> > +/* smi register */
> > +#define SMI_BUSY		(1<<28)	/* 0 - Write, 1 - Read  */
> > +#define SMI_R_VALID		(1<<27)	/* 0 - Write, 1 - Read  */
> > +#define SMI_OP_W		(0<<26)	/* Write operation      */
> > +#define SMI_OP_R		(1<<26)	/* Read operation */

It was recently suggested to me that an enum be used at times like this.

> 
> (1 << 28)
> (1 << 27)
> (0 << 26)
> 
> etc (thoughout the file)

[snip]
