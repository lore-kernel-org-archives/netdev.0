From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: use correct accessors for scatterlists
Date: Mon, 26 Jan 2009 21:00:55 -0800 (PST)
Message-ID: <20090126.210055.104964648.davem@davemloft.net>
References: <20090124001053.GA20156@ovro.caltech.edu>
	<200901271521.19616.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iws@ovro.caltech.edu, linux-kernel@vger.kernel.org,
	markmc@redhat.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42810
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbZA0FA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:00:58 -0500
In-Reply-To: <200901271521.19616.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 27 Jan 2009 15:21:19 +1030

> On Saturday 24 January 2009 10:40:53 Ira Snyder wrote:
> > Without this fix, virtio_net makes incorrect usage of scatterlists. It sets
> > the end of the scatterlist chain after the first element, despite the fact
> > that more entries come after it.
> > 
> > If you try to run dma_map_sg() on one of the scatterlists given to you by
> > add_buf(), you will get a null pointer oops.
> > 
> > Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> 
> Thanks, this should go in 2.6.29.  Dave?

Applied, should I queue it up for -stable too Rusty?

Thanks.
