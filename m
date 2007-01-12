From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 17:53:05 +0100
Message-ID: <200701121753.06014.mb@bu3sch.de>
References: <45a713f4.CVklfeegOYfmrIW+%Larry.Finger@lwfinger.net>
	<200701121517.40539.mb@bu3sch.de> <45A7B914.4030804@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45A7B914.4030804-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Friday 12 January 2007 17:36, Larry Finger wrote:
> Michael Buesch wrote:
> 
> I have one general question before I address your comments. Does a BCM43xx chip always have either a
> PCI or a PCI-E core? I've seen discussion on this list that makes me wonder. That is why I had some
> explicit tests for PCI-E in the code.

Ok, I see your point.
I don't think we have devices without PCI core.
BUT:
If you think there are devices without a PCI core, you
must not switch to it in the first place. So your check is
worthless nevertheless, because in case of no PCI core you
have crashed much earlier anyway. ;)

If we have a PCI core (and I think we always have), it can only
be PCI or PCIE.

-- 
Greetings Michael.
