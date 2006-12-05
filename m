From: Paul Collins <paul-uANAyHgy5MnD+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape
	git pull..
Date: Tue, 05 Dec 2006 13:28:05 +1300
Message-ID: <8764cr190q.fsf@briny.internal.ondioline.org>
References: <45733FBF.5020800@gmail.com>
	<87y7pogj1k.fsf@briny.internal.ondioline.org>
	<45745D2B.1090700@gmail.com>
	<87ac231ari.fsf@briny.internal.ondioline.org>
	<45746370.4070205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Robert Martin <robertm83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
In-Reply-To: <45746370.4070205-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Robert Martin's message of "Mon\, 04
	Dec 2006 13\:05\:36 -0500")
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

(Please use reply-to-all to keep Cc:s intact, and place new material
below quoted material.)

Robert Martin <robertm83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Paul Collins wrote:
>> Robert Martin <robertm83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
>>> Alas, that seems to have been the problem, I was getting different
>>> frequencies.  Once I manually set the frequency, dhclient worked
>>> perfectly.  The only problem now is that I seem to be limited to very
>>> slow speeds (on the order of 5-20K/s, or ~120 kilobits/s).
>>
>> I guess the speed problem is due to the general state of BCM4318
>> support, as mentioned by the developers.
>>
>> I'm glad the frequency thing isn't some weird glitch that only I am
>> experiencing though.
>>
> I'm pretty sure that I'm using a 4311 chip... lspci -n gives...
>
> 03:00.0 0280: 14e4:4311 (rev 01)
>
> ...I might have been mistaken about it being a PCI-E chip in that
> case.  One additional question, it seems the link quality is very low;
> "iwconfig wlan0" tells me it's 3/100 after associating with my AP.
> Could that be the power issue that Johannes Berg was speaking of?  I'm
> curious as to what speeds you're running at, and what your link
> quality is.

My card (a 4306) seems to be running at 11Mbps.  No idea how to change
it: iwconfig doesn't report the current rate (I had to go digging in
sysfs) and trying to change it with iwconfig fails with "Operation not
supported".

Here's the signal info:

        Link Quality=228/100  Signal level=-32 dBm  Noise level=-70 dBm

The machine is about 3 metres from the AP.

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
