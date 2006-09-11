From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Mon, 11 Sep 2006 09:37:19 -0500
Message-ID: <4505749F.9090808@lwfinger.net>
References: <45006221.4090603@lwfinger.net>
	<20060908094204.GB26916@harddisk-recovery.com>
	<200609081145.28095.mb@bu3sch.de>
	<20060908132317.GS26916@harddisk-recovery.com>
	<450171E4.8070901@lwfinger.net>
	<20060911105202.GA7903@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Erik Mouw <erik-7jKlSzr1t1+rFW3l5+5NieqUGfbH9hYC@public.gmane.org>
In-Reply-To: <20060911105202.GA7903-7jKlSzr1t1+rFW3l5+5NieqUGfbH9hYC@public.gmane.org>
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

Erik Mouw wrote:
> On Fri, Sep 08, 2006 at 08:36:36AM -0500, Larry Finger wrote:
>> Erik Mouw wrote:
>>> Thanks for the information, pulled wireless-2.6 and recompiling kernel.
>>> If this really fixes the problem, can we try to get it merged before
>>> 2.6.18 closes? I don't know if vanilla 2.6.18-rc6 locks up on other
>>> hardware as well, but if it does it would be a major regression against
>>> 2.6.17.
>> I'm trying. At the moment, I'm testing a patch against 2.6.18-rc6. Once it works here, I'll be 
>> putting it out for testing.
> 
> I suppose that's the patch in "[PATCH] fix for system lockups in
> 2.6.18-rcX caused by bcm43xx"?

Yes.
> 
> FWIW: 2.6.18-rc6+wireless-2.6 runs well, my laptop didn't lock up over
> the weekend.

It seems to hurt some hardware much worse than others. My BCM4306 Rev 2 could
not run without failure longer than ~6 hours, and sometimes as short as 10 minutes,
before the patch. I've now completed the equivalent of 3 weeks without a failure
(I'm running the preemptible periodic work every second instead of every minute).

Larry
