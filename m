From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH take2] softmac: remove netif_tx_disable when scanning
Date: Tue, 28 Nov 2006 15:21:24 +0100
Message-ID: <200611281521.24861.mb@bu3sch.de>
References: <456B4C81.mail5401KMW2R@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <456B4C81.mail5401KMW2R-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Monday 27 November 2006 21:37, Larry Finger wrote:
> From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
> 
> In the scan section of ieee80211softmac, network transmits are disabled.
> When SoftMAC re-enables transmits, it may override the wishes of a driver
> that may have very good reasons for disabling transmits. At least one failure
> in bcm43xx can be traced to this problem. In addition, several unexplained
> problems may arise from the unexpected enabling of transmits.


> Note that 
> making this change introduces a new bug that would allow transmits for the
> current session to be transmitted on the wrong channel;

Nono, please don't confuse that.
It does not _indruduce_ a new bug. The bug is already there. It's only less
likely to trigger without this bugfix patch.

> however, the new bug 
> is much less severe than the one being fixed, as the new one only leads to
> a few retransmits, whereas the old one can bring the interface down.

Yeah, that too.

-- 
Greetings Michael.
