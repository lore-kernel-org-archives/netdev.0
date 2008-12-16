From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 05/14] gianfar: Fix eTSEC configuration
 procedure
Date: Tue, 16 Dec 2008 15:30:28 -0800 (PST)
Message-ID: <20081216.153028.166276428.davem@davemloft.net>
References: <1229469667-25002-4-git-send-email-afleming@freescale.com>
	<1229469667-25002-5-git-send-email-afleming@freescale.com>
	<1229469667-25002-6-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755733AbYLPXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:30:26 -0500
In-Reply-To: <1229469667-25002-6-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:20:58 -0600

> Fix some bugs in the ethtool configuration functions:
> * gfar_clean_rx_ring should not be called with interrupts disabled.
> * Update last transmission time to avoid tx timeout.
> * Delete redundant NETIF_F_IP_CSUM check in gfar_start_xmit
> * Use netif_tx_lock_bh when reconfiguring the tx csum
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
