From: Erik Mouw <erik-7jKlSzr1t1+rFW3l5+5NieqUGfbH9hYC@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Mon, 11 Sep 2006 12:52:02 +0200
Message-ID: <20060911105202.GA7903@harddisk-recovery.com>
References: <45006221.4090603@lwfinger.net>
	<20060908094204.GB26916@harddisk-recovery.com>
	<200609081145.28095.mb@bu3sch.de>
	<20060908132317.GS26916@harddisk-recovery.com>
	<450171E4.8070901@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <450171E4.8070901-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Fri, Sep 08, 2006 at 08:36:36AM -0500, Larry Finger wrote:
> Erik Mouw wrote:
> > Thanks for the information, pulled wireless-2.6 and recompiling kernel.
> > If this really fixes the problem, can we try to get it merged before
> > 2.6.18 closes? I don't know if vanilla 2.6.18-rc6 locks up on other
> > hardware as well, but if it does it would be a major regression against
> > 2.6.17.
> 
> I'm trying. At the moment, I'm testing a patch against 2.6.18-rc6. Once it works here, I'll be 
> putting it out for testing.

I suppose that's the patch in "[PATCH] fix for system lockups in
2.6.18-rcX caused by bcm43xx"?

FWIW: 2.6.18-rc6+wireless-2.6 runs well, my laptop didn't lock up over
the weekend.


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
