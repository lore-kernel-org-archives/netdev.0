From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: pull-request: can-next 2013-01-26
Date: Mon, 28 Jan 2013 06:58:29 +0100
Message-ID: <51061385.9070108@hartkopp.net>
References: <5103FFA3.5020507@pengutronix.de> <20130128.002455.638752456075920210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20130128.002455.638752456075920210.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28.01.2013 06:24, David Miller wrote:

> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Sat, 26 Jan 2013 17:09:07 +0100
> 
>> this is a pull-request for net-next/master. There is are 9 patches by 
>> Fabio Baltieri and Kurt Van Dijck which add LED infrastructure and
>> support for CAN devices. Bernd Krumboeck adds a driver for the USB CAN
>> adapter from 8 devices. Oliver Hartkopp improves the CAN gateway
>> functionality. There are 4 patches by me, which clean up the CAN's
>> Kconfig.
> 
> Pulled, although:
> 
> 1) You need to create an accessor helper for that can_skb_priv
>    thing, every access to it is that horrible cast expression.


Ok, will do.

> 
> 2) There is no reason to accomodate out of tree stuff, and for that
>    reason I see no reason why you should need that headroom size
>    check at all.
> 
>    Either the driver uses alloc_can_skb() or it does it's own SKB
>    allocation and in-tree you've fixed that.
> 
>    You're just asking for trouble by trying to accomodate out of
>    tree guys anyways, why if they create a headroom that happens
>    to be the size of can_skb_priv.  See what a joke that test is?
>    It's not really protecting fully against anything.


I see.

I'll remove the check and try to inform the few out of tree guys that i'm
aware of.

Thanks,
Oliver
