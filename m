From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] simnet: convert to net_device_ops
Date: Tue, 09 Dec 2008 22:57:28 -0800 (PST)
Message-ID: <20081209.225728.07389385.davem@davemloft.net>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
	<20081209150827.GA8134@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20081209150827.GA8134@x200.localdomain>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 9 Dec 2008 18:08:27 +0300

> On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
> >   CC      arch/ia64/hp/sim/simeth.o
> > arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> > arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'
> 
> [PATCH] simeth: convert to net_device_ops
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

This doesn't explain the build failure.

Using ->open() and friends should work perfectly fine for drivers not
yet converted to netdev_ops.  The code protected by COMPAT_NET_DEV_OPS
provides this, and we force that Kconfig option to always be on.

I don't want to add this patch and just shrug off this build failure.
If this build failures, we should be seeing 200 other drivers not
build too.

I suspect something is messed up with this person's kernel config
or similar.
