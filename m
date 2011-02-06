From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Proper netdev->ndo_set_rx_mode()
 implementation.
Date: Sun, 06 Feb 2011 11:25:59 -0800 (PST)
Message-ID: <20110206.112559.48508425.davem@davemloft.net>
References: <201102061850.40458.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753851Ab1BFTZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 14:25:24 -0500
In-Reply-To: <201102061850.40458.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Sun, 6 Feb 2011 18:50:40 +0200

> Completed the bnx2x_set_rx_mode() to a proper netdev->ndo_set_rx_mode 
> implementation: 
>  - Added a missing configuration of a unicast MAC addresses list.
>  - Changed bp->dma_lock from being a mutex to a spinlock as long as it's taken
> under netdev->addr_list_lock now.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
