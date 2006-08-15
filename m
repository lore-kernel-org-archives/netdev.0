From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-d80211: Init, shutdown and restart fixes
Date: Tue, 15 Aug 2006 17:30:25 +0200
Message-ID: <200608151730.26255.mb@bu3sch.de>
References: <200608142132.25398.mb@bu3sch.de> <44E1E6E6.9000804@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <44E1E6E6.9000804-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Tuesday 15 August 2006 17:23, Larry Finger wrote:
> Michael,
> 
> Michael Buesch wrote:
> > Hi John,
> > 
> > Please apply this to wireless-dev.
> > 
> > --
> > 
> > This fixes various bugs in the init and shutdown code
> > that would lead to lockups and crashes.
> > This is best reproducable by receiving a timeout from
> > the netdev watchdog.
> 
> Is a similar bug likely to be the cause of the netdev watchdog timeouts in 
> bcm43xx-softmac? If so, will there be a patch for wireless-2.6?

I don't know why the _timeouts_ itself happen, but maybe the
lockup and crash bugs are in bcm43xx-softmac, too.
I think it should be actually trivial to port this to bcm43xx-softmac.
Care to do this, Larry?

-- 
Greetings Michael.
