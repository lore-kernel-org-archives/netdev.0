From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Do interrupt mode initialization and
 NAPIs adding before register_netdev()
Date: Wed, 24 Nov 2010 11:10:05 -0800 (PST)
Message-ID: <20101124.111005.59662591.davem@davemloft.net>
References: <1290612078.27220.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754253Ab0KXTJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:09:40 -0500
In-Reply-To: <1290612078.27220.2.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 24 Nov 2010 17:21:18 +0200

> Move the interrupt mode configuration and NAPIs adding before a
> register_netdev() call to prevent netdev->open() from running
> before these functions are done.
> 
> Advance a driver version number.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> Reported-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks.
