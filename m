From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 14 Jul 2006 08:49:03 +0200
Message-ID: <20060714064903.GA8355@lst.de>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net> <20060707.165527.77037268.davem@davemloft.net> <20060708104811.GB31751@lst.de> <20060708.133738.123994596.davem@davemloft.net> <20060713203615.GA26954@lst.de> <20060714072726.GB6458@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, netdev@vger.kernel.org, support@pathscale.com,
	kkeil@suse.de, kai.germaschewski@gmx.de, chas@cmf.nrl.navy.mil,
	paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:24248 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030337AbWGNGtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 02:49:39 -0400
To: Samuel Ortiz <samuel@sortiz.org>
Content-Disposition: inline
In-Reply-To: <20060714072726.GB6458@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2006 at 10:27:27AM +0300, Samuel Ortiz wrote:
> > The patchkit for this is at http://verein.lst.de/~hch/patches.skb.tgz, it
> > includes the first two cleanup patches I posted previously (Any plans
> > to put them in?), a patch to move __dev_alloc_skb out of line because
> > otherwise we'd need to include netdevice.h in skbuff.h which creates
> > lots of problems (and moving it out of lines shaves 10kb off a
> > allyesconfig), the dev_alloc_skb prototype changes and some experimental
> > patches to make dev_alloc_skb nodeaware.
> In those patches you change dev_alloc_skb prototype, but then the new netdev
> argument is not used by __dev_alloc_skb() to allocate the sk_buff on the
> correct node. Do you plan to introduce an alloc_skb_node() later or am I 
> missing something ? 

The nodeaware-skb_alloc patch later in the series introduces a node
argument to __alloc_skb.  the nodeaware-netdev patch adds a node
argument to struct netdevice that dev_alloc_skb then passes to
__alloc_skb.  All of these patches are in the tarball my previous mail
points to.
