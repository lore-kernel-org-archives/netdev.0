From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v9 20/20] pch_can: Replace netif_rx to
	netif_receive_skb
Date: Tue, 14 Dec 2010 11:16:04 +0900
Message-ID: <98ED21118B7A4639B9AB0B8FFE323179@hacdom.okisemi.com>
References: <1292221467-8039-18-git-send-email-tomoya-linux@dsn.okisemi.com><1292221467-8039-19-git-send-email-tomoya-linux@dsn.okisemi.com><1292221467-8039-20-git-send-email-tomoya-linux@dsn.okisemi.com>
	<20101213.122826.27813399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

Thank you for your acceptance.

> Hi Marc and Wolfgang
Until now, thank you for your much help!

---
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.

----- Original Message ----- 
From: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Cc: <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>; <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; <chripell-VaTbYqLCNhc@public.gmane.org>; 
<21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; 
<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; 
<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; 
<yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; 
<joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sent: Tuesday, December 14, 2010 5:28 AM
Subject: Re: [PATCH net-next-2.6 v9 20/20] pch_can: Replace netif_rx to 
netif_receive_skb


> From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> Date: Mon, 13 Dec 2010 15:24:26 +0900
>
>> Since this driver is implemented as NAPI,
>> netif_receive_skb must be used not netif_rx.
>>
>> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>
> Applied.
> 
