From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] simnet: convert to net_device_ops
Date: Wed, 10 Dec 2008 14:54:17 +0300
Message-ID: <20081210115417.GC20973@x200.localdomain>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com> <20081209150827.GA8134@x200.localdomain> <20081209.225728.07389385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.beregalov@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081209.225728.07389385.davem@davemloft.net>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 09, 2008 at 10:57:28PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 9 Dec 2008 18:08:27 +0300
> 
> > On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
> > >   CC      arch/ia64/hp/sim/simeth.o
> > > arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> > > arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'
> > 
> > [PATCH] simeth: convert to net_device_ops
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> This doesn't explain the build failure.

I triggered it manually.

And most certainly forgot .ndo_validate_addr, so patch needs resend anyway.

> Using ->open() and friends should work perfectly fine for drivers not
> yet converted to netdev_ops.  The code protected by COMPAT_NET_DEV_OPS
> provides this, and we force that Kconfig option to always be on.
> 
> I don't want to add this patch and just shrug off this build failure.
> If this build failures, we should be seeing 200 other drivers not
> build too.
> 
> I suspect something is messed up with this person's kernel config
> or similar.
