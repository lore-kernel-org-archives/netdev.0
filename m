From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: optimization of DMA bitfields.]
Date: Wed, 16 Aug 2006 11:02:00 -0500
Message-ID: <44E34178.8040303@lwfinger.net>
References: <44E33B7A.3060804@lwfinger.net> <1155742963.3600.39.camel@ux156>
	<44E33F3E.2000509@lwfinger.net> <200608161757.37807.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200608161757.37807.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

Michael Buesch wrote:
> On Wednesday 16 August 2006 17:52, Larry Finger wrote:
>> Johannes Berg wrote:
>>> On Wed, 2006-08-16 at 10:36 -0500, Larry Finger wrote:
>>>> +	/* Boolean. Is this a TX ring? */
>>>> +	u8 tx
>>>> +	/* Boolean. 64bit DMA if true, 32bit DMA otherwise. */
>>>> +	u8 dma64;
>>> does that compile?
>>>
>>> johannes
>>>
>> Yes, it did here. Did you have a problem?
> 
> You removed a ; by mistake.
> Look, it's there in my original patch (which was compile tested).
> 
I saw that just after I sent the response to Johannes. I don't know
how that ; got deleted, but a revised version will be on to John soon.

Larry
