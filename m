From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-d80211: Init, shutdown and restart fixes
Date: Tue, 15 Aug 2006 11:44:45 -0400
Message-ID: <20060815154440.GD28544@tuxdriver.com>
References: <200608142132.25398.mb@bu3sch.de> <44E1E6E6.9000804@lwfinger.net>
	<200608151730.26255.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200608151730.26255.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

On Tue, Aug 15, 2006 at 05:30:25PM +0200, Michael Buesch wrote:
> On Tuesday 15 August 2006 17:23, Larry Finger wrote:
> > Michael Buesch wrote:

> > > This fixes various bugs in the init and shutdown code
> > > that would lead to lockups and crashes.
> > > This is best reproducable by receiving a timeout from
> > > the netdev watchdog.
> > 
> > Is a similar bug likely to be the cause of the netdev watchdog timeouts in 
> > bcm43xx-softmac? If so, will there be a patch for wireless-2.6?
> 
> I don't know why the _timeouts_ itself happen, but maybe the
> lockup and crash bugs are in bcm43xx-softmac, too.
> I think it should be actually trivial to port this to bcm43xx-softmac.
> Care to do this, Larry?

Actually, this leads to a bigger question.  I noticed Michael
pleading his support dilemma w.r.t. supporting both wireless-2.6
and wirless-dev.  I'm sure he now regrets the "stunt" of trying to
support both at the same time... :-)

Anyway, it would seem like many of these fixes would be readily ported
between the trees.  It seems like we need someone to take-on this
(admittedly thankless) maintainence task from now until the new stack
merges into wireless-2.6.

Larry, you seem like a great candidate for this role.  Are you
interested?  If not, is there someone else in the bcm43xx camp that
would oblige us?

Thanks in advance!

John

P.S.  FWIW, I definitely thank Michael for his work supporting both
stack to date.  I think the dscape stack would be much farther behind
w/o the users enabled by the bcm43xx-dscape driver.
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
