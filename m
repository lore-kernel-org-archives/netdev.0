From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] bnx2x: avoid TX timeout when stopping device
Date: Mon, 17 May 2010 17:35:47 -0700 (PDT)
Message-ID: <20100517.173547.116387300.davem@davemloft.net>
References: <20100517123406.GA2504@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com,
	dmitry@broadcom.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753560Ab0ERAfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:35:38 -0400
In-Reply-To: <20100517123406.GA2504@dhcp-lab-161.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Mon, 17 May 2010 14:34:06 +0200

> When stop device call netif_carrier_off() just after disabling TX queue to
> avoid possibility of netdev watchdog warning and ->ndo_tx_timeout() invocation.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
