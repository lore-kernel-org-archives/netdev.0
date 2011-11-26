From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Sat, 26 Nov 2011 15:59:17 +0100
Message-ID: <4ED0FEC5.3070108@hartkopp.net>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1322214204-1121-3-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,

many thanks for posting this driver. Indeed this is the last from the missing
drivers in the SVN ...

I added Wolfgang Zarre to the list of recipients who tested your CC770 driver
recently:

http://old.nabble.com/Compile-Fails-On-2.6.39-2-td32259346.html

Maybe he can check this latest version and can send a "Tested-by:"

@Wolfgang Zarre: The entire patch set from Wolfgang Grandegger is here:

http://patchwork.ozlabs.org/patch/127653/
http://patchwork.ozlabs.org/patch/127651/
http://patchwork.ozlabs.org/patch/127654/
http://patchwork.ozlabs.org/patch/127652/

Just a nitpick in the description:

> Furthermore, the following mode parameter can be defined:

> 
>   clk: External oscillator clock frequency (default=16000000 [16 MHz])
>   cir: CPU interface register (default=0x40 [DSC])
>   ocr, Bus configuration register (default=0x40 [CBY])


-> bcr: CPU ...

>   cor, Clockout register (default=0x00)


-> cor: Clockout ...

Regards,
Oliver
