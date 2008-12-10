From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] simnet: convert to net_device_ops
Date: Wed, 10 Dec 2008 15:25:24 -0800 (PST)
Message-ID: <20081210.152524.226506156.davem@davemloft.net>
References: <20081209150827.GA8134@x200.localdomain>
	<20081209.225728.07389385.davem@davemloft.net>
	<a4423d670812100321qc93060evd0d3ae3f78418b29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbYLJXZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 18:25:23 -0500
In-Reply-To: <a4423d670812100321qc93060evd0d3ae3f78418b29@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Wed, 10 Dec 2008 14:21:46 +0300

> 2008/12/10 David Miller <davem@davemloft.net>:
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > Date: Tue, 9 Dec 2008 18:08:27 +0300
> >
> >> On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
> >> >   CC      arch/ia64/hp/sim/simeth.o
> >> > arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> >> > arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'
> >>
> >> [PATCH] simeth: convert to net_device_ops
> >>
> >> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> >
> > This doesn't explain the build failure.
> >
> > Using ->open() and friends should work perfectly fine for drivers not
> > yet converted to netdev_ops.  The code protected by COMPAT_NET_DEV_OPS
> > provides this, and we force that Kconfig option to always be on.
> >
> > I don't want to add this patch and just shrug off this build failure.
> > If this build failures, we should be seeing 200 other drivers not
> > build too.
> >
> > I suspect something is messed up with this person's kernel config
> > or similar.
> >
> 
> Thanks for explanation.
> Is it better?

Good fix, except that your email client corrupted the patch
by turning tab characters into spaces.

I fixed this up and applied your patch.  But please next
time provide a proper Signed-off-by line too.
