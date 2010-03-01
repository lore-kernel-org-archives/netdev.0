From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Sun, 28 Feb 2010 18:49:33 -0800 (PST)
Message-ID: <20100228.184933.158431788.davem@davemloft.net>
References: <1267351922.10409.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgruszka@redhat.com, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753186Ab0CACtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:49:15 -0500
In-Reply-To: <1267351922.10409.2.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 28 Feb 2010 12:12:02 +0200

> [Resending with the proper subject. Sorry for the mess. ]
> 
> This patch is based on the RFC of Stanislaw Gruszka.
> 
> More specifically it fixes two possible races:
> - One, described by Stanislaw, may lead to permanent disabling of the Tx
> queue.
> This is fixed by adding the smp_wmb() to propagate the BD consumer
> change towards the memory.
> - Second may lead to bnx2x_start_xmit() returning NETDEV_TX_BUSY.
> This is fixed by taking a tx_lock() before rechecking the number of
> available Tx BDs.
> 
> thanks,
> vlad 
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks everyone.
