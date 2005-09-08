From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Wed, 07 Sep 2005 21:49:13 -0400
Message-ID: <431F9899.4060602@pobox.com>
References: <200509080125.j881PcL9015847@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932559AbVIHBtV@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
In-Reply-To: <200509080125.j881PcL9015847@hera.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> tree 1771b690cdee80312ace3fe046e29e965a0b30eb
> parent c8d127418d78aaeeb1a417ef7453dc09c9118146
> author Tommy S. Christensen <tommy.christensen@tpack.net> Wed, 07 Sep 2005 05:17:28 -0700
> committer Linus Torvalds <torvalds@g5.osdl.org> Thu, 08 Sep 2005 06:57:30 -0700
> 
> [PATCH] 3c59x: read current link status from phy
> 
> The phy status register must be read twice in order to get the actual link
> state.
> 
> Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> 
>  drivers/net/3c59x.c |    1 +
>  1 files changed, 1 insertion(+)
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -1889,6 +1889,7 @@ vortex_timer(unsigned long data)
>  		{
>  			spin_lock_bh(&vp->lock);
>  			mii_status = mdio_read(dev, vp->phys[0], 1);
> +			mii_status = mdio_read(dev, vp->phys[0], 1);

It would be nice if somebody would be motivated to check in 
s/1/MII_BMSR/ to utilize the constant in include/linux/mii.h.

	Jeff
