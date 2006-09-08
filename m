From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Fri, 08 Sep 2006 08:36:36 -0500
Message-ID: <450171E4.8070901@lwfinger.net>
References: <45006221.4090603@lwfinger.net>
	<20060908094204.GB26916@harddisk-recovery.com>
	<200609081145.28095.mb@bu3sch.de>
	<20060908132317.GS26916@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Erik Mouw <erik-7jKlSzr1t1+rFW3l5+5NieqUGfbH9hYC@public.gmane.org>
In-Reply-To: <20060908132317.GS26916-7jKlSzr1t1+rFW3l5+5NieqUGfbH9hYC@public.gmane.org>
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
> On Fri, Sep 08, 2006 at 11:45:27AM +0200, Michael Buesch wrote:
>> The crash is fixed in wireless-2.6.
>> The actual cause of the controller restart not. So at least it
>> does not crash anymore.
> 
> Thanks for the information, pulled wireless-2.6 and recompiling kernel.
> If this really fixes the problem, can we try to get it merged before
> 2.6.18 closes? I don't know if vanilla 2.6.18-rc6 locks up on other
> hardware as well, but if it does it would be a major regression against
> 2.6.17.

I'm trying. At the moment, I'm testing a patch against 2.6.18-rc6. Once it works here, I'll be 
putting it out for testing.

Larry
