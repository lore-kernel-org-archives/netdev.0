From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next-2.6 v9 20/20] pch_can: Replace netif_rx to	netif_receive_skb
Date: Mon, 13 Dec 2010 22:51:32 +0100
Message-ID: <4D069564.8070204@hartkopp.net>
References: <1292221467-8039-18-git-send-email-tomoya-linux@dsn.okisemi.com>	<1292221467-8039-19-git-send-email-tomoya-linux@dsn.okisemi.com>	<1292221467-8039-20-git-send-email-tomoya-linux@dsn.okisemi.com> <20101213.122826.27813399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tomoya-linux@dsn.okisemi.com, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:37239 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246Ab0LMVvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 16:51:40 -0500
In-Reply-To: <20101213.122826.27813399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.12.2010 21:28, David Miller wrote:
> From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
> Date: Mon, 13 Dec 2010 15:24:26 +0900
> 
>> Since this driver is implemented as NAPI,
>> netif_receive_skb must be used not netif_rx.
>>
>> Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Applied.

Do you plan to push this huge patchset to Linus' 2.6.37-rc5 tree?

I wonder if the pch_can driver in linux-2.6 tree is already usable without
these latest patches that have been applied only to net-next-2.6.

Regards,
Oliver


