From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: let the MII driver inform a MAC about changed wire
 speed
Date: Wed, 16 Apr 2008 14:36:58 -0400
Message-ID: <4806474A.3020502@garzik.org>
References: <83116F0A4FF67A4F97BA0B6E408C48E301F22BDD@zuerich.BC-Int.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Wappler Marcel <Marcel.Wappler@bridgeco.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbYDPShB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 14:37:01 -0400
In-Reply-To: <83116F0A4FF67A4F97BA0B6E408C48E301F22BDD@zuerich.BC-Int.NET>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wappler Marcel wrote:
> This was tested on a ARM926 base SoC with an IP based ethernet MAC (10/100 MBit) together with a Realtek RTL8201 MII and a SMCSC
> 8700 RMII with kernel 2.6.24.
> 
> ---
> An Ethernet MAC needs to know the medium speed (10/100/1000 Mbps) of an RMII PHY in order to correctly interpret data originating
> from that PHY. The function mii_check_media() has been extended to allow retrieval of the medium speed by a MAC driver. A trivial
> modification to existing MAC drivers will allow them to cover operation with both MII and RMII PHYs.
> Signed-off-by: Marcel Wappler <marcel.wappler@bridgeco.net>

Please make sure to copy netdev list...

Queued for review.

	Jeff



