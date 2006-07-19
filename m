From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Wireless statistics for bcm43xx-d80211
Date: Wed, 19 Jul 2006 14:42:01 -0500
Message-ID: <44BE8B09.3080107@lwfinger.net>
References: <44BDB400.40408@lwfinger.net>
	<1153317379.2537.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <1153317379.2537.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> 
> Actually, now that I think about it, why are _any_ applets
> screen-scraping /proc/net/wireless anymore?  If they profess to be a
> wireless applet, yet screenscrape /proc/net/wireless, that's suspect
> right there.  The ioctls for status are quite well-defined and haven't
> changed in a very long time (ie, SIOCGIWRANGE).
> 
> On the flip side, /proc/net/wireless has been supported since the dawn
> of time (ok, not really) and is the textual interface for reporting
> wireless statistic, but maybe that shouldn't be the case anymore.
> 

I finally found the source for the applet, and it is using iwlib to get the statistics. If the 
kernel's version of WE is really old, it will use /proc/net/wireless. For newer kernels, it is using 
the appropriate ioctl. When I get time, I will fix the error and submit a patch to KDE.

As an interim workaround, I downloaded and built kwlaninfo, a different KDE kicker applet. I don't 
like it very much but it does show the needed info.

Larry
