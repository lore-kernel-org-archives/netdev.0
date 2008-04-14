From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Sink IPv6 options into its own submenu
Date: Sun, 13 Apr 2008 21:43:19 -0700 (PDT)
Message-ID: <20080413.214319.245612757.davem@davemloft.net>
References: <alpine.LNX.1.10.0803311145520.2554@fbirervta.pbzchgretzou.qr>
	<20080403.141028.154673064.davem@davemloft.net>
	<alpine.LNX.1.10.0804060603590.30794@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751248AbYDNEnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:43:18 -0400
In-Reply-To: <alpine.LNX.1.10.0804060603590.30794@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Sun, 6 Apr 2008 06:04:25 +0200 (CEST)

> commit 9ad0be1e95f326b03ccc513ec1cb5cc618ab2811
> parent a5b2db67139e991d9e9e19260989d0e66a03a2b2
> Author: Jan Engelhardt <jengelh@computergmbh.de>
> Date:   Mon Mar 31 11:44:02 2008 +0200
> 
>      [NET]: Sink IPv6 menuoptions into its own submenu
> 
>      Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>

Your email client corrupted the patch.

> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -3,7 +3,7 @@
>   #
> 
>   #   IPv6 as module will cause a CRASH if you try to unload it
> -config IPV6
> +menuconfig IPV6
>   	tristate "The IPv6 protocol"
>   	default m
>   	---help---

After the "+" line there should be one space then a tab,
instead there are two spaces and a tab.

I think there is some standard pine/alpine setting change
that gets rid of this problem.
