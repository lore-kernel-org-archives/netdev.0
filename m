From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Latest fixes to bcm43xx-d80211 now available as patch to 2.6.18
Date: Fri, 06 Oct 2006 11:24:50 -0500
Message-ID: <45268352.7010504@lwfinger.net>
References: <45259659.9040804@lwfinger.net>
	<51ad2e0d0610060137n5cc2bf4cna4a4a68ccedd94e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Bin Zhang <yangtze31-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
In-Reply-To: <51ad2e0d0610060137n5cc2bf4cna4a4a68ccedd94e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Bin Zhang wrote:
>  CC [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.o
>  LD [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx-d80211.o
>  LD      drivers/net/wireless/built-in.o
> ld: drivers/net/wireless/d80211/built-in.o: No such file: No such file
> or directory
> make[3]: *** [drivers/net/wireless/built-in.o] Error 1
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Initially I had seen that error, but thought it was fixed. A new version has been uploaded that 
builds correctly from a 'make clean' - please try it.

Also, please note Johannes Berg's comments regarding the increased interrupt usage for V4 firmware.

Larry
