From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 13:25:55 -0500
Message-ID: <4569DC33.8050208@gentoo.org>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>	
	<45691273.9090803@gentoo.org>
	<1164535408.21459.3.camel@johannes.berg>	
	<4569C2D0.8080406@gentoo.org>
	<1164559882.22909.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1164559882.22909.5.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
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

Johannes Berg wrote:
> Would you actually need a fully refcounted enable/disable?

No, we could stick with our existing setup if the stack did something 
different.

> Because for
> the stack it wouldn't be required if it'd simply not start scanning when
> queue is disabled and stop scanning immediately when queue stop is
> requested.

That would work, assuming there is a way to make the stack listen for 
the "TX queue stopped" event (or would the ieee80211_tx_disable wrapper 
take care of that?).

Daniel
