From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Mon, 28 Nov 2011 17:06:48 +0100
Message-ID: <4ED3B198.2040308@hartkopp.net>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED37885.8080909-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
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


>> ... using a reasonable default for bcr of 0x40. But you may need to
>> provide better values for cir, bcr and cor.
>>
> 
> OMG, sorry that I was bothering You but You are absolutely right and with Your
> statement You brought be back on track and You made my day. Thank You !!!!!!
> 
> I just took the values for cpu and bus I was using in my lincan driver and funny
> enough now it's working absolutely perfect.
> 
> Module: modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
> 
> Was just sending 50000 telegrams, perfect and no problem at all.
> 
> Thanks a lot again!!!!
> 


This looks like a Tested-by :-)

Thanks Wolfgang (who ever feels addressed)
