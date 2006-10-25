From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Fwd: [PATCH] bcm43xx: (hopefully) fix watchdog timeouts.
Date: Wed, 25 Oct 2006 11:38:38 +0200
Message-ID: <200610251138.39036.mb@bu3sch.de>
References: <200610241631.18911.mb@bu3sch.de>
	<20061025003726.GC7340@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
In-Reply-To: <20061025003726.GC7340-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
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

On Wednesday 25 October 2006 02:37, John W. Linville wrote:
> Michael,
> 
> It looks like you have a patch that I don't have, one that moves the
> netif_tx_disable and spin_lock_irqsave outside of the "if (badness >
> BADNESS_LIMIT)" conditional.
> 
> Could you pass that one along as well, or correct this patch to match
> what is in Linus' tree?

Well, I'm not sure who moved the tx_disable outside of the
conditional. It is not needed. We only need to disable TX on
the slowpath (the first branch of the if condition). It does not
hurt to disable it always, though.
But I will send a new patch against wireless-2.6, which only disables
TX for the slowpath and fakes a TX there.

But for Greg, the original patch is ok.
How was the stable mailing list again? stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org seems to bounce.

-- 
Greetings Michael.
