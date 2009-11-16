From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 16:33:56 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950BFF@zin33exm22.fsl.freescale.net>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com><20091116.022012.81633492.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net> <20091116.024130.156214496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <vladz@broadcom.com>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57276 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbZKPLDx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:03:53 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nAGB3xWD002468
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 04:03:59 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id nAGB3wBk020336
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 05:03:59 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091116.024130.156214496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>> Can we actually introduce NAPI mechanism for cleaning TX ring ??
>
>You really should if you can.
>
>Preferably you should combine it with RX work in a shared NAPI context
>(1 TX queue + 1 RX queue per NAPI context, for example), doing 
>the TX reclaim first in your ->poll() routine, before the RX 
>processing, because this TX reclaim provides freshly freed up 
>SKBs for RX work that generates responses (TCP ACKs, etc.)
>

I was talking about an independent napi routine for cleaning tx ring, I
do not want to mix the rx and tx clean ring processes.



--
Thanks
Sandee
