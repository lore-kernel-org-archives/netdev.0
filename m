From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v9 20/20] pch_can: Replace netif_rx to
 netif_receive_skb
Date: Mon, 13 Dec 2010 19:45:42 -0800 (PST)
Message-ID: <20101213.194542.193715300.davem@davemloft.net>
References: <1292221467-8039-20-git-send-email-tomoya-linux@dsn.okisemi.com>
	<20101213.122826.27813399.davem@davemloft.net>
	<4D069564.8070204@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomoya-linux@dsn.okisemi.com, netdev@vger.kernel.org,
	mkl@pengutronix.de, wg@grandegger.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59828
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752927Ab0LNDpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 22:45:14 -0500
In-Reply-To: <4D069564.8070204@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 13 Dec 2010 22:51:32 +0100

> On 13.12.2010 21:28, David Miller wrote:
>> From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
>> Date: Mon, 13 Dec 2010 15:24:26 +0900
>> 
>>> Since this driver is implemented as NAPI,
>>> netif_receive_skb must be used not netif_rx.
>>>
>>> Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
>>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> 
>> Applied.
> 
> Do you plan to push this huge patchset to Linus' 2.6.37-rc5 tree?
> 
> I wonder if the pch_can driver in linux-2.6 tree is already usable without
> these latest patches that have been applied only to net-next-2.6.

I'm happy to take the changes for a backport once all of this settles
down which I don't believe it has yet.
