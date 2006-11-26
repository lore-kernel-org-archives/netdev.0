From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 13:03:09 -0600
Message-ID: <4569E4ED.3020507@lwfinger.net>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net> <45691273.9090803@gentoo.org>
	<1164535408.21459.3.camel@johannes.berg>
	<4569C2D0.8080406@gentoo.org>
	<1164559882.22909.5.camel@johannes.berg>
	<4569DC33.8050208@gentoo.org>
	<1164566436.22909.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1164566436.22909.26.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
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
> On Sun, 2006-11-26 at 13:25 -0500, Daniel Drake wrote:
> 
>> No, we could stick with our existing setup if the stack did something 
>> different.
> 
> But you do need full refcounting I guess.
> 
>>> Because for
>>> the stack it wouldn't be required if it'd simply not start scanning when
>>> queue is disabled and stop scanning immediately when queue stop is
>>> requested.
>> That would work, assuming there is a way to make the stack listen for 
>> the "TX queue stopped" event (or would the ieee80211_tx_disable wrapper 
>> take care of that?).
> 
> A wrapper is what I had in mind, I don't think there's any notification
> for these things.

If someone will prepare a patch that will fix this, I can test it. Otherwise, I'm prepared to 
substitute the bug that doesn't hurt anything for the one that I have shown does cause problems.

Larry
