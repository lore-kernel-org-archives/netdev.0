From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Mon, 11 Sep 2006 16:35:04 -0400
Message-ID: <20060911203458.GD19326@tuxdriver.com>
References: <45021D4A.6040805@lwfinger.net>
	<20060909152305.GA27080@tuxdriver.com>
	<4502E62B.5060601@lwfinger.net>
	<20060911192846.GB19326@tuxdriver.com>
	<4505C005.2070302@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4505C005.2070302-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 11, 2006 at 02:59:01PM -0500, Larry Finger wrote:
> John W. Linville wrote:

> >Also, if you could just use "---" instead of a long line of "======",
> >I think I would have to do less manual processing...thanks!
> 
> Sorry about the === rather than ---. Is that documented somewhere?

Not too explicitly, but I think Andrew mentions it in "The Perfect Patch":

	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

While you are looking, you might review Jeff's version of the same idea:

	http://linux.yyz.us/patch-format.html
 
> I use quilt to generate the patches, but will check them with git in 
> the future.

It's not terribly critical, but it does slow me down if I have to
regenerate patches, edit comments, change subject lines, etc.

> In addition to the items listed above, my list for wireless-2.6 includes:
> 
> 8/15  bcm43xx: >1G and 64bit DMA support
> 8/15  bcm43xx: re-add bcm43xx_rng_init() call
> 8/15  Add Larry Finger to bcm43xx MAINTAINERS
> 8/16  bcm43xx-softmac: optimization of DMA bitfields.
> 8/19  bcm43xx: return correct hard_start_xmit error code]

I have all of these in the upstream branch of wireless-2.6.  BTW,
I have _not_ applied the Init patch yet. But I still have it, so I'll
just combine that w/ the new patch you posted this afternoon.

> 9/10  Change PHY initialization to match updated clean-room specs

The archives show this as being posted today at ~2:00pm EDT, but I
seem to have missed it?  Could you resend it just to me?

> I hope I'm not causing too much trouble while I learn the ropes.

We all go through it -- if you start feeding another maintainer,
he/she will probably have other quirks too... :-)

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
