From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Wireless statistics for bcm43xx-d80211
Date: Wed, 19 Jul 2006 14:59:27 +0200
Message-ID: <200607191459.27451.mb@bu3sch.de>
References: <44BDB400.40408@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <44BDB400.40408-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
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

On Wednesday 19 July 2006 06:24, Larry Finger wrote:
> I have gotten most things working to produce wireless statistics through /proc/net/wireless for
> bcm43xx-d80211; however, I have one problem that I have not yet been able to solve. When I do a 'cat
> /proc/net/wireless', the following is printed:
> 
> Inter-| sta-|   Quality        |   Discarded packets               | Missed | WE
>   face | tus | link level noise |  nwid  crypt   frag  retry   misc | beacon | 20
> wmaster0: 0000  100.    0.    0.       0      0      0      0      0        0
>   wlan1: 0000  100.  -26.  -67.       0      0      0      0      0        0
> 
> Based on the numbers obtained using bcm43xx-softmac for my interface, the numbers for level and 
> noise for wlan1 are what I expected (in dBm). The link value has not yet been finished. The main 
> problem is that the wireless kicker applet for KDE, which I use for a display, is only looking at 
> the first line, 

So it is broken. Fullstop.
Bug KDE for this.

-- 
Greetings Michael.
